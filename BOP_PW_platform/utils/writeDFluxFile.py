import sys
import data_IO

# Input arguments:

if len(sys.argv) < 3:
    print("Number of provided arguments: ", len(sys.argv) - 1)
    print("Usage: python writeDFluxFile <fortranFile.f> <inputFile.in>")
    sys.exit()

fortranFileAddress = sys.argv[1]
inputFileAddress = sys.argv[2]

# Read parameters from input file
fInput = data_IO.open_file(inputFileAddress, "r")

a = data_IO.read_float_from_file_pointer(fInput, "weld_a")
b = data_IO.read_float_from_file_pointer(fInput, "weld_b")
c = data_IO.read_float_from_file_pointer(fInput, "weld_c")

x0 = data_IO.read_float_from_file_pointer(fInput, "weld_x0")
y0 = data_IO.read_float_from_file_pointer(fInput, "weld_y0")
z0 = data_IO.read_float_from_file_pointer(fInput, "weld_z0")

Q = data_IO.read_float_from_file_pointer(fInput, "weld_Q")

vx = data_IO.read_float_from_file_pointer(fInput, "weld_vx")
vy = data_IO.read_float_from_file_pointer(fInput, "weld_vy")
vz = data_IO.read_float_from_file_pointer(fInput, "weld_vz")

fInput.close()

# Write the BC fortran file

fortranFile = data_IO.open_file(fortranFileAddress, "w")

fortranFile.write('! NEED THIS HEADER INFORMATION  \n'
                  '  \n'
                  '      subroutine dflux(flux,sol,kstep,kinc,time,noel,npt,coords,  \n'
                  '     &     jltyp,temp,press,loadtype,area,vold,co,lakonl,konl,  \n'
                  '     &     ipompc,nodempc,coefmpc,nmpc,ikmpc,ilmpc,iscale,mi,  \n'
                  '     &     sti,xstateini,xstate,nstate_,dtime)  \n'
                  '  \n'
                  '      character*8 lakonl  \n'
                  '      character*20 loadtype  \n'
                  '!  \n'
                  '      integer kstep,kinc,noel,npt,jltyp,konl(20),ipompc(*),nstate_,i,  \n'
                  '     &  nodempc(3,*),nmpc,ikmpc(*),ilmpc(*),node,idof,id,iscale,mi(*)  \n'
                  '!  \n'
                  '      real*8 flux(2),time(2),coords(3),sol,temp,press,vold(0:mi(2),*),  \n'
                  '     &  area,co(3,*),coefmpc(*),sti(6,mi(1),*),xstate(nstate_,mi(1),*),  \n'
                  '     &  xstateini(nstate_,mi(1),*),dtime  \n'
                  '!  \n'
                  '      intent(in) sol,kstep,kinc,time,noel,npt,coords,  \n'
                  '     &     jltyp,temp,press,loadtype,area,vold,co,lakonl,konl,  \n'
                  '     &     ipompc,nodempc,coefmpc,nmpc,ikmpc,ilmpc,mi,sti,  \n'
                  '     &     xstateini,xstate,nstate_,dtime  \n'
                  '       \n'
                  '      intent(out) flux,iscale  \n'
                  '  \n'
                  '! END OF HEADER INFORMATION  \n'
                  '! CUSTOM SUBROUTINE HERE  \n'
                  '       \n'
                  '       !  effective welding arc for surface heatflux a,b  *Body heatflux a,b,c[mm]   \n')

fortranFile.write('	  a = ' + str(a) + '\n')
fortranFile.write('	  b = ' + str(b) + '\n')
fortranFile.write('	  c = ' + str(c) + '\n')

fortranFile.write('	    \n')

fortranFile.write('	  x0 = ' + str(x0) + '\n')
fortranFile.write('	  y0 = ' + str(y0) + '\n')
fortranFile.write('	  z0 = ' + str(z0) + '\n')

fortranFile.write('	    \n'
                  '	  !  Path 1 Linear moving heat source   \n'
                  '      ! speed of welding in x direction is 2m/sec  \n')

fortranFile.write('	  vx=' + str(vx) + '\n')
fortranFile.write('	  vy=' + str(vy) + '\n')
fortranFile.write('	  vz=' + str(vz) + '\n')

fortranFile.write('	    \n'
                  '	  xarc=vx*time(1)+x0  \n'
                  '	  yarc=vy*time(1)+y0  \n'
                  '	  zarc=vz*time(1)+z0  \n'
                  '   \n'
                  '	  Xf=coords(1)-xarc	! coordinate of position x   \n'
                  '	  Yf=coords(2)-yarc	! coordinate of position y   \n'
                  '	  Zf=coords(3)-zarc	! coordinate of position z  \n'
                  '        \n'
                  '      ! heat flux core : current220*voltage14*efficiency0.7  \n')

fortranFile.write('	  Q=' + str(Q) + '\n')

fortranFile.write('        \n'
                  '      heat=1.86632*Q/(a*b*c)  \n'
                  '      shapef=EXP(-3*(Xf)**2./a**2.-3*(Yf)**2./b**2.-3*(Zf)**2./c**2.)  \n'
                  '  \n'
                  '	  flux(1)=heat*shapef  \n'
                  '  \n'
                  '      RETURN  \n'
                  '      END  \n')


fortranFile.close()
