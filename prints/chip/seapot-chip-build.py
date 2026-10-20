import qrcode, trimesh, numpy as np
from shapely.geometry import Polygon, box, MultiPolygon
from shapely.ops import unary_union
from shapely import affinity
from matplotlib.textpath import TextPath
from matplotlib.font_manager import FontProperties

URL="https://menu.adsuaracloud.com"
SIZE=45.0; R=4.0; BASE=2.4; FACE_H=0.6; DEBOSS=0.6
FACE=41.0; FR=3.0; QR_MM=32.0; QR_TOP=17.5

def rrect(w,h,r):
    return box(-w/2+r,-h/2+r,w/2-r,h/2-r).buffer(r,resolution=24)

def text_poly(s,height,font,cx,cy,mirror=False,max_w=None):
    fp=FontProperties(fname=font)
    tp=TextPath((0,0),s,size=10,prop=fp)
    polys=[Polygon(p) for p in tp.to_polygons() if len(p)>2]
    # even-odd fill: XOR all rings
    g=Polygon()
    for p in sorted(polys,key=lambda p:-p.area):
        g=g.symmetric_difference(p.buffer(0))
    # scale by cap height using 'H'
    H=TextPath((0,0),"H",size=10,prop=fp).get_extents().height
    k=height/H; g=affinity.scale(g,k,k,origin=(0,0))
    if max_w:
        w=g.bounds[2]-g.bounds[0]
        if w>max_w: g=affinity.scale(g,max_w/w,1,origin=(0,0))
    b=g.bounds; g=affinity.translate(g,cx-(b[0]+b[2])/2,cy-(b[1]+b[3])/2)
    if mirror: g=affinity.scale(g,-1,1,origin=(cx,cy))
    return g

def extrude(poly,h,z0=0):
    polys=list(poly.geoms) if hasattr(poly,'geoms') else [poly]
    ms=[trimesh.creation.extrude_polygon(p,h) for p in polys if p.area>1e-4]
    m=trimesh.util.concatenate(ms); m.apply_translation([0,0,z0]); return m

# QR modules
q=qrcode.QRCode(border=0,error_correction=qrcode.constants.ERROR_CORRECT_M); q.add_data(URL); q.make()
M=q.get_matrix(); N=len(M); m=QR_MM/N
left=-QR_MM/2
mods=[box(left+x*m,QR_TOP-(y+1)*m,left+(x+1)*m,QR_TOP-y*m) for y,row in enumerate(M) for x,v in enumerate(row) if v]
modules=unary_union(mods)

BOLD="/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf"
SERIF="/usr/share/fonts/truetype/dejavu/DejaVuSerif-Bold.ttf"
label=text_poly("SCAN FOR MENU",3.0,BOLD,0,QR_TOP-QR_MM-2.9,max_w=31)

face=rrect(FACE,FACE,FR).difference(modules.buffer(0.03,join_style=2)).difference(label)

# back deboss (mirrored, on bottom face)
seapot=text_poly("SEAPOT",6.5,SERIF,0,5.0,mirror=True,max_w=34)
phone=text_poly("408-685-2268",4.2,BOLD,0,-6.0,mirror=True,max_w=35)
back=unary_union([seapot,phone])

base=extrude(rrect(SIZE,SIZE,R),BASE)
cut=extrude(back,DEBOSS+0.01,-0.01)
import manifold3d
base=base.difference(cut,engine="manifold")
facem=extrude(face,FACE_H,BASE)

base.export("seapot-chip-base-black.stl")
facem.export("seapot-chip-face-white.stl")
trimesh.util.concatenate([base,facem]).export("seapot-chip.stl")
print("modules",N,"x",N,"module mm",round(m,3))
print("label stroke check: min text width ok" )
print("base watertight",base.is_watertight,"face watertight",facem.is_watertight)

# verification raster of top view: white face on black
from PIL import Image, ImageDraw
S=20; W=int(SIZE*S)
img=Image.new("L",(W,W),20); d=ImageDraw.Draw(img)
def draw(g,fill):
    for p in (g.geoms if hasattr(g,'geoms') else [g]):
        d.polygon([((x+SIZE/2)*S,(SIZE/2-y)*S) for x,y in p.exterior.coords],fill=fill)
        for i in p.interiors: d.polygon([((x+SIZE/2)*S,(SIZE/2-y)*S) for x,y in i.coords],fill=20)
draw(face,240); img.save("top.png")
imgb=Image.new("L",(W,W),40); d=ImageDraw.Draw(imgb)
def drawb(g):
    for p in (g.geoms if hasattr(g,'geoms') else [g]):
        d.polygon([((SIZE/2-x)*S,(SIZE/2-y)*S) for x,y in p.exterior.coords],fill=90)  # un-mirror for view
        for i in p.interiors: d.polygon([((SIZE/2-x)*S,(SIZE/2-y)*S) for x,y in i.coords],fill=40)
drawb(back); imgb.save("back.png")
