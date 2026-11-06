import sys, subprocess, numpy as np
f=sys.argv[1]; W,H=1920,1080
raw=subprocess.run(['ffmpeg','-loglevel','error','-i',f,'-f','rawvideo','-pix_fmt','gray','-'],capture_output=True).stdout
a=np.frombuffer(raw,np.uint8).reshape(H,W).astype(float)
m=a>float(sys.argv[2]) if len(sys.argv)>2 else a>15
def fit(pts):  # x = p0*y+p1 or y = p0*x + p1
    pts=np.array(pts); c=np.polyfit(pts[:,0],pts[:,1],1); r=pts[:,1]-np.polyval(c,pts[:,0]); 
    k=np.abs(r)<3*np.std(r)+1; return np.polyfit(pts[k,0],pts[k,1],1)
L=[];R=[];T=[];B=[]
for y in range(200,880,10):
    xs=np.nonzero(m[y,100:1900])[0]
    if len(xs)>500: L.append((y,xs[0]+100)); R.append((y,xs[-1]+100))
for x in range(700,1550,10):
    ys=np.nonzero(m[50:1050,x])[0]
    if len(ys)>400: T.append((x,ys[0]+50)); B.append((x,ys[-1]+50))
l,r,t,b=fit(L),fit(R),fit(T),fit(B)
def cross(v,h): # v: x=a*y+b ; h: y=c*x+d
    y=(h[0]*v[1]+h[1])/(1-h[0]*v[0]); return (v[0]*y+v[1], y)
for n,(v,h) in dict(TL=(l,t),TR=(r,t),BL=(l,b),BR=(r,b)).items(): print(n,'%.1f %.1f'%cross(v,h))
import math
print('top slope deg %.2f  bottom %.2f  left %.2f right %.2f'%tuple(math.degrees(math.atan(s)) for s in (t[0],b[0],l[0],r[0])))
