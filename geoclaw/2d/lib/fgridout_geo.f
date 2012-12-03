
c======================================================================
      subroutine fgridout(fgrid1,fgrid2,fgrid3,xlowfg,xhifg,ylowfg,
     &           yhifg,mxfg,myfg,mvarsfg,mvarsfg2,toutfg,ioutfg,ng,
     &           ioutarrival,ioutflag)
c======================================================================


      implicit double precision (a-h,o-z)

      dimension fgrid1(1:mxfg,1:myfg,mvarsfg)
      dimension fgrid2(1:mxfg,1:myfg,mvarsfg)
      dimension fgrid3(1:mxfg,1:myfg,mvarsfg2)

      character*30 fgoutname

c=====================FGRIDOUT==========================================
c         # This routine interpolates in time and then outputs a grid at
c         # time=toutfg

c         #files have a header, followed by columns of data
c=======================================================================

c        ###  make the file names and open output files
      fgoutname = 'fort.fgnn_xxxx'
      ngridnumber= ng
      do ipos = 9, 8, -1
          idigit= mod(ngridnumber,10)
          fgoutname(ipos:ipos) = char(ichar('0') + idigit)
          ngridnumber = ngridnumber/ 10
      enddo

      noutnumber=ioutfg
      do ipos = 14, 11, -1
          idigit = mod(noutnumber,10)
          fgoutname(ipos:ipos) = char(ichar('0') + idigit)
          noutnumber = noutnumber / 10
      enddo

      open(unit=90,file=fgoutname,status='unknown',
     &       form='formatted')

 1002 format(
     &       e18.8,'    time', /,
     &          i5,'    mx', /,
     &          i5,'    my', /,
     &       e18.8,'    xlow',/,
     &       e18.8,'    ylow',/,
     &       e18.8,'    xhi',/,
     &       e18.8,'    yhi',/,
     &          i5,'  columns',/)


      icolumns = mvarsfg -1
      if (mvarsfg2.gt.1) then
         icolumns=icolumns + 2
      endif


      write(90,1002) toutfg,mxfg,myfg,xlowfg,ylowfg,xhifg,yhifg,
     &                                               icolumns

 109       format(8e26.16)

      indetamin = ioutarrival+2
      indetamax = ioutarrival+3
        
c     # interpolate the grid in time, to the output time, using 
c     # the solution in fgrid1 and fgrid2, which represent the 
c     # solution on the fixed grid at the two nearest computational times

      do jfg=1,myfg
      do ifg=1,mxfg
        t0=fgrid1(ifg,jfg,mvarsfg)
        tf=fgrid2(ifg,jfg,mvarsfg)
        tau=(toutfg-t0)/(tf-t0)
        do iv=1,mvarsfg-1
            if (dabs(fgrid1(ifg,jfg,iv)) .lt. 1d-90) 
     &               fgrid1(ifg,jfg,iv) = 0.d0
            if (dabs(fgrid2(ifg,jfg,iv)) .lt. 1d-90) 
     &               fgrid2(ifg,jfg,iv) = 0.d0
            enddo
       if (icolumns.eq.mvarsfg-1) then 
        write(90,109) ((1.d0 - tau)*fgrid1(ifg,jfg,iv)
     &            +tau*fgrid2(ifg,jfg,iv), iv=1,mvarsfg-1)
       else
        if (dabs(fgrid3(ifg,jfg,indetamin)) .lt. 1d-90)
     &           fgrid3(ifg,jfg,indetamin) = 0.d0
        if (dabs(fgrid3(ifg,jfg,indetamax)) .lt. 1d-90)
     &           fgrid3(ifg,jfg,indetamax) = 0.d0
        write(90,109) ((1.d0 - tau)*fgrid1(ifg,jfg,iv)
     &            +tau*fgrid2(ifg,jfg,iv), iv=1,mvarsfg-1),
     &            fgrid3(ifg,jfg,indetamin),fgrid3(ifg,jfg,indetamax)

       endif
      enddo
      enddo

      close(unit=90)

 111  format(' FGRIDOUT: Fixed Grid  ', i2, '  frame ',i2,
     &       ' at time =', e18.8)
      write(*,111) ng, ioutfg, toutfg

c==================== Output for arrival times============
      if (ioutflag.eq.1) then
c        ###  make the file name and open output file for arrival times
      fgoutname = 'fort.fgnn_arrivaltimes'
      ngridnumber= ng
      do ipos = 9, 8, -1
          idigit= mod(ngridnumber,10)
          fgoutname(ipos:ipos) = char(ichar('0') + idigit)
          ngridnumber = ngridnumber/ 10
      enddo

      open(unit=95,file=fgoutname,status='unknown',
     &       form='formatted')

 1005 format(
     &          i5,'    mx', /,
     &          i5,'    my', /,
     &       e18.8,'    xlow',/,
     &       e18.8,'    ylow',/,
     &       e18.8,'    xhi',/,
     &       e18.8,'    yhi',/)


      write(95,1005) mxfg,myfg,xlowfg,ylowfg,xhifg,yhifg


 167       format(1e26.16)

      do jfg=1,myfg
      do ifg=1,mxfg

        write(95,167) fgrid3(ifg,jfg,1)
  
      enddo
      enddo

      close(unit=95)

 112  format(' FGRIDOUT: Fixed Grid  ', i2, '  arrival times output')
      write(*,112) ng
      endif
c=====================================================================


      return
      end
