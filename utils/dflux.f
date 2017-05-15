! NEED THIS HEADER INFORMATION

      subroutine dflux(flux,sol,kstep,kinc,time,noel,npt,coords,
     &     jltyp,temp,press,loadtype,area,vold,co,lakonl,konl,
     &     ipompc,nodempc,coefmpc,nmpc,ikmpc,ilmpc,iscale,mi,
     &     sti,xstateini,xstate,nstate_,dtime)

      character*8 lakonl
      character*20 loadtype
!
      integer kstep,kinc,noel,npt,jltyp,konl(20),ipompc(*),nstate_,i,
     &  nodempc(3,*),nmpc,ikmpc(*),ilmpc(*),node,idof,id,iscale,mi(*)
!
      real*8 flux(2),time(2),coords(3),sol,temp,press,vold(0:mi(2),*),
     &  area,co(3,*),coefmpc(*),sti(6,mi(1),*),xstate(nstate_,mi(1),*),
     &  xstateini(nstate_,mi(1),*),dtime
!
      intent(in) sol,kstep,kinc,time,noel,npt,coords,
     &     jltyp,temp,press,loadtype,area,vold,co,lakonl,konl,
     &     ipompc,nodempc,coefmpc,nmpc,ikmpc,ilmpc,mi,sti,
     &     xstateini,xstate,nstate_,dtime
     
      intent(out) flux,iscale

! END OF HEADER INFORMATION
! CUSTOM SUBROUTINE HERE
     
       !  effective welding arc for surface heatflux a,b  *Body heatflux a,b,c[mm] 
       a = 0.5
       b = 0.5
       c = 1

	  x0=-5
	  y0=0
	  z0=0
	  
	  !  Path 1 Linear moving heat source 
      ! speed of welding in x direction is 2m/sec
        vx = 10
        vy = 0.00
        vz = 0.00
      	  
	  xarc=vx*time(1)+x0
	  yarc=vy*time(1)+y0
	  zarc=vz*time(1)+z0
 
	  Xf=coords(1)-xarc	! coordinate of position x 
	  Yf=coords(2)-yarc	! coordinate of position y 
	  Zf=coords(3)-zarc	! coordinate of position z
      
      ! heat flux core : current220*voltage14*efficiency0.7
      Q=10000.
      
      heat=1.86632*Q/(a*b*c)
      shapef=EXP(-3*(Xf)**2./a**2.-3*(Yf)**2./b**2.-3*(Zf)**2./c**2.)

	  flux(1)=heat*shapef

      RETURN
      END
