

      subroutine ft_adv( &
        Nf, &
        xf, yf, & ! front position
        uf, vf, & ! front quantity
        u, v, &
        nx, ny, dx, dy, dt)
      implicit none
      integer, intent(in) :: Nf
      double precision, intent(inout) :: xf(1:Nf+2), yf(1:Nf+2)
      double precision, intent(out) :: uf(1:Nf+2), vf(1:Nf+2)
      integer, intent(in) :: nx, ny
      double precision, intent(in) :: dx, dy, dt
      double precision, intent(in) :: u(nx+2,ny+2), v(nx+2,ny+2)
      !
      integer :: l
      integer :: ip, jp
      double precision :: ax, ay
      
      do l = 2, Nf+1
        ip = floor(xf(l)/dx) + 1
        jp = floor((yf(l)+0.5d0*dy)/dy) + 1
        ax = xf(l)/dx - ip + 1
        ay = (yf(l)+0.5d0*dy)/dy - jp + 1
        uf(l) = (1.0d0-ax)*(1.0d0-ay)*u(ip,jp) &
          + ax*(1.0d0-ay)*u(ip+1,jp) &
          + (1.0d0-ax)*ay*u(ip,jp+1) &
          + ax*ay*u(ip+1,jp+1)
        
        ip = floor((xf(l)+0.5d0*dx)/dx) + 1
        jp = floor(yf(l)/dy) + 1
        ax = (xf(l)+0.5d0*dx)/dx - ip + 1
        ay = yf(l)/dy - jp + 1
        vf(l) = (1.0d0-ax)*(1.0d0-ay)*v(ip,jp) &
          + ax*(1.0d0-ay)*v(ip+1,jp) &
          + (1.0d0-ax)*ay*v(ip,jp+1) &
          + ax*ay*v(ip+1,jp+1)
      enddo
      
      ! enforce wall node
      if (.true.) then
        uf(2) = 0.0d0
        uf(Nf+1) = 0.0d0
      endif
      
      do l = 2, Nf+1
        xf(l) = xf(l) + dt*uf(l)
        yf(l) = yf(l) + dt*vf(l)
      enddo
      
      ! set ghost node
      call ft_bndry_pos(Nf, xf,yf)
      
      
      return
      end subroutine ft_adv
      
      subroutine ft_recons( &
        Nf, &
        xf, yf, & ! front position
        dx, dy)
      use front_module, only: maxnf
      implicit none
      integer, intent(inout) :: Nf
      double precision, intent(inout) :: xf(1:maxnf+2), yf(1:maxnf+2)
      double precision, intent(in) :: dx, dy
      !
      integer :: l, cnt
      double precision :: xfold(1:maxnf+2), yfold(1:maxnf+2)
      double precision :: ds
      
      xfold(:) = xf(:)
      yfold(:) = yf(:)
      !cnt = 1
      cnt = 2
      do l = 3, Nf+1
        ds = sqrt(((xfold(l)-xf(cnt))/dx)**2 + ((yfold(l)-yf(cnt))/dy)**2)
        if (ds > 0.5d0) then
          cnt = cnt + 1
          xf(cnt) = 0.5 * (xfold(l) + xf(cnt-1))
          yf(cnt) = 0.5 * (yfold(l) + yf(cnt-1))
          cnt = cnt + 1
          xf(cnt) = xfold(l)
          yf(cnt) = yfold(l)
        elseif (ds < 0.25d0 .and. l.ne.Nf+1) then
        !elseif (ds < 0.0d0) then
          ! do nothing
        else
          cnt = cnt + 1
          xf(cnt) = xfold(l)
          yf(cnt) = yfold(l)
        endif
      enddo
      
      Nf = cnt - 1
      
      ! ghost nodes
      call ft_bndry_pos(Nf, xf,yf)
      
      return
      end subroutine ft_recons
      
      
      ! Set ghost nodes
      subroutine ft_bndry_pos( &
        Nf, xf, yf)
      implicit none
      integer, intent(in) :: Nf
      double precision, intent(inout) :: xf(1:Nf+2), yf(1:Nf+2)
      !
      
      if (.false.) then
        xf(1) = xf(Nf+1)
        yf(1) = yf(Nf+1)
        xf(Nf+2) = xf(2)
        yf(Nf+2) = yf(2)
      else
        ! reflective ghosts
        
        ! xf(2) = 0.0d0
        ! xf(Nf+1) = 0.0d0
        
        xf(1) = 2.0d0*xf(2) - xf(3)
        yf(1) = yf(3)
        
        xf(Nf+2) = 2.0d0*xf(Nf+1) -xf(Nf)
        yf(Nf+2) = yf(Nf)
      endif
      
      return
      end subroutine ft_bndry_pos









