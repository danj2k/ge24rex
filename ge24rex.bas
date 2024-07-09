ON ERROR VDU23,1,1,0;0;0;0;:CLS:END
MODE 7
HIMEM=&48FF
tc%=649
tp%=15
cc%=0
sm%=0
ss$=STRING$(60," "):ss$=""
sr%=0
cm%=TRUE
DIM pc$(19)
VDU23,1,0;0;0;0;
PROCsetup
PROCload_data
PROCshow_instructions
PROCmain_menu
END

DEFPROCsetup
	VDU 31,0,0,132,157,131
	VDU 31,0,1,132,157,131
	PRINT TAB(6,0);CHR$(141);"#UKGE2024 Results Explorer";CHR$(140)
	PRINT TAB(6,1);CHR$(141);"#UKGE2024 Results Explorer";CHR$(140)
	VDU 31,39,0,156
	VDU 31,39,1,156
	?&7FC0=131
	?&7FC1=157
	?&7FC2=132
	?&7FE7=156
	PRINT TAB(7,24);"Press f1 for instructions";
	VDU 28,0,23,39,2
ENDPROC

DEFPROCload_data
	VDU 31,12,10,136
	PRINT "Please wait...";CHR$(137)
	VDU 31,14,11
	PRINT "LOADING DATA";
	*LOAD GE24DAT 4900
ENDPROC

DEFFNget_party(pid%)
	pp%=(?&4900 + ?&4901 * &100) + &4900
	mem% = pp% + (pid% * 2)
	po% = (?mem% + ?(mem%+1) * &100) + &4900
=$po%

DEFFNget_cons(cid%)
	cp%=&4902 + (cid% * 2)
	mem% = (?cp% + ?(cp%+1) * &100) + &4901
	cl% = ?mem%
	mem% = mem% + 1
	cn$=STRING$(80," "):cn$=""
	fl% = TRUE
	po%=0
	FOR en% = 1 TO cl%
		po% = (?mem% + ?(mem%+1) * &100) + &4900
		word$ = $po%
		IF word$ = "-" OR word$ = "," THEN fl% = FALSE
		IF word$ = "," THEN word$ = ", "
		IF en% > 1 AND fl% THEN cn$ = cn$ + " "
		cn$ = cn$ + word$
		IF word$ <> "-" AND word$ <> ", " AND NOT fl% THEN fl% = TRUE
		mem% = mem% + 2
	NEXT en%
=cn$

DEFFNget_winner(cid%)
	cp%=&4902 + (cid% * 2)
	mem% = (?cp% + ?(cp%+1) * &100) + &4900
	res% = ?mem%
	wn% = (res% AND &0F) - 1
=FNget_party(wn%)

DEFFNget_loser(cid%)
	cp%=&4902 + (cid% * 2)
	mem% = (?cp% + ?(cp%+1) * &100) + &4900
	res% = ?mem%
	ln% = res% DIV 16
	IF ln% = 0 THEN loser$="None" ELSE ln% = ln% - 1:loser$=FNget_party(ln%)
=loser$

DEFPROCshow_cursor
	pgp% = cc% MOD 19
	VDU 31,0,(1+pgp%),136,&5D,137
ENDPROC

DEFPROChide_cursor
	pgp% = cc% MOD 19
	VDU 31,0,(1+pgp%),32,32,32
ENDPROC

DEFPROCmove_cursor(dir%)
	nc% = cc% + dir%
	IF nc% < 0 OR nc% >= tc% THEN VDU 7:ENDPROC
	pn% = cc% DIV 19
	np% = nc% DIV 19
	IF np% <> pn% THEN cc% = nc%:cm% = TRUE:PROCshow_current_page:ENDPROC
	PROChide_cursor
	cc% = nc%
	PROCshow_cursor
ENDPROC

DEFFNpad_spaces_right(text$,tln%)
	IF LEN(text$)>=tln% THEN =text$
=text$ + STRING$(tln%-LEN(text$)," ")

DEFPROCshow_search_bar
	IF sm% = 0 THEN PRINT TAB(0,21);STRING$(37," ");:?&7FBF=32
	IF LEN(ss$) > 13 THEN ds$ = LEFT$(ss$,13) ELSE ds$=FNpad_spaces_right(ss$,13)
	IF sm% = 1 AND sr% > 0 THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search constituency: ";ds$;:?&7FBF=156
	IF sm% = 2 AND sr% > 0 THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search winner: ";ds$;:?&7FBF=156
	IF sm% = 3 AND sr% > 0 THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search loser: ";ds$;:?&7FBF=156
	IF sr% < 0 THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"No results";STRING$(23," ");:?&7FBF=156:sm% = 0:ss$ = "":sr% = 0
ENDPROC

DEFPROCshow_current_page
	CLS
	VDU 31,0,1
	pn% = cc% DIV 19
	REM Starting constituency
	cs% = pn% * 19
	ce% = cs% + 18
	IF ce% > (tc% - 1) THEN ce% = tc% - 1
	FOR cid% = cs% TO ce%
		pgp% = cid% - cs%
		IF cm% THEN cn$ = FNget_cons(cid%):pc$(pgp%)=cn$
		IF LEN(pc$(pgp%)) > 34 THEN PRINT TAB(3);LEFT$(pc$(pgp%),34) ELSE PRINT TAB(3);pc$(pgp%)
	NEXT cid%
	cm% = FALSE
	PROCshow_search_bar
	PROCshow_cursor
ENDPROC

DEFPROCshow_instructions
	CLS
	PRINT TAB(14,2);"Instructions"
	PRINT TAB(5,4);CHR$(134);"Arrow keys";CHR$(135);" Highlight choices"
	PRINT TAB(9,5);CHR$(134);"RETURN";CHR$(135);" Confirm choice"
	PRINT TAB(3,6);CHR$(134);"SHIFT+arrows";CHR$(135);" Page up/down"
	PRINT TAB(13,7);CHR$(129);"f1";CHR$(135);" Toggle instructions"
	PRINT TAB(13,8);CHR$(129);"f3";CHR$(135);" Search/Find next"
	PRINT TAB(7,9);CHR$(129);"SHIFT+f3";CHR$(135);" Clear search"
	PRINT TAB(6,11);"Available search types are:"
	PRINT TAB(5,12);CHR$(130);"constituency,";CHR$(129);"winner,";CHR$(134);"loser";CHR$(135);
	REPEAT UNTIL INKEY(-114)
	REPEAT UNTIL NOT INKEY(-114)
ENDPROC

DEFPROCword_wrap(text$)
	li%=1
	REPEAT
		line$=""
		old_line$ = ""
		oli% = 1
		rtp% = FALSE
		REPEAT
			IF li% < LEN(text$) AND MID$(text$,li%,1)=" " THEN old_line$=line$:oli%=li%
			line$ = line$ + MID$(text$,li%,1)
			li% = li%+1
			IF LEN(line$) > 34 THEN line$=old_line$:li%=oli%+1:rtp% = TRUE
		UNTIL rtp% OR li% > LEN(text$)
		PRINT " ";line$
	UNTIL li% > LEN(text$)
ENDPROC

DEFPROCshow_constituency
	CLS
	pgp% = cc% MOD 19
	PROCword_wrap(pc$(pgp%))
	PRINT ""
	PRINT " Result: ";
	winner$ = FNget_winner(cc%)
	loser$ = FNget_loser(cc%)
	IF loser$ = "None" THEN PRINT winner$;" hold" ELSE PRINT winner$;" gain from ";loser$
	PRINT ""
	PRINT " Press RETURN to go back to the menu.";
	REPEAT UNTIL INKEY(-74)
	REPEAT UNTIL NOT INKEY(-74)
ENDPROC

DEFFNcustom_input
	*FX21,0
	PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);STRING$(33," ");:?&7FBF=156
	PRINT TAB(3,21);"Search string: ";CHR$(255);
	key%=0
	ud% = FALSE
	ci$ = ""
	REPEAT
		key%=GET
		IF key%=32 OR key%=44 OR key%=45 THEN ci$ = ci$ + CHR$(key%):ud% = TRUE
		IF (key%>64 AND key%<91) OR (key%>96 AND key%<123) THEN ci$ = ci$ + CHR$(key%):ud% = TRUE
		IF (key%=8 OR key%=127) AND LEN(ci$)>0 THEN ci$=LEFT$(ci$,LEN(ci$)-1):ud% = TRUE
		IF ud% THEN ud% = FALSE:PRINT TAB(18,21);FNpad_spaces_right(RIGHT$(ci$,18)+CHR$(255),19);
	UNTIL key%=13
	REPEAT UNTIL NOT INKEY(-74)
=ci$

DEFFNpad_spaces_centre(text$,tln%)
	IF LEN(text$)>=tln% THEN =text$
	ls% = (tln% - LEN(text$)) DIV 2
	rs% = (tln% - LEN(text$)) DIV 2
	IF ((tln% - LEN(text$)) MOD 2)<>0 THEN ls% = ls% + 1
=STRING$(ls%," ") + text$ + STRING$(rs%," ")

DEFFNsearch_party
	*FX21,0
	PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);STRING$(33," ");:?&7FBF=156
	pc% = 0
	PRINT TAB(3,21);"Search";
	rt$ = ""
	IF sm% = 2 THEN rt$ = " winner:" ELSE rt$ = " loser: "
	PRINT rt$;CHR$(136);"[";CHR$(137);FNpad_spaces_centre(FNget_party(pc%),8);CHR$(136);"]";CHR$(137);:?&7FBF=156
	old_pc% = pc%
	REPEAT
		IF INKEY(-26) THEN pc% = pc% - 1:ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF INKEY(-122) THEN pc% = pc% + 1:ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF pc% < 0 THEN pc% = tp%-1
		IF pc% >= tp% THEN pc% = 0
		IF old_pc%<>pc% THEN PRINT TAB(17,21);CHR$(136);"[";CHR$(137);FNpad_spaces_centre(FNget_party(pc%),8);CHR$(136);"]";CHR$(137);:?&7FBF=156
		old_pc% = pc%
	UNTIL INKEY(-74)
	REPEAT UNTIL NOT INKEY(-74)
=FNget_party(pc%)
	
DEFPROCsearch
	IF sm% > 0 THEN sc%=cc%+1:GOTO 2440
	sm% = 1
	PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search mode:";CHR$(136);"[";CHR$(137);"constituency";CHR$(136);"]";CHR$(137);:?&7FBF=156
	osm% = sm%
	REPEAT
		IF INKEY(-26) THEN sm% = sm% - 1:ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF INKEY(-122) THEN sm% = sm% + 1:ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF sm% < 1 THEN sm% = 3
		IF sm% > 3 THEN sm% = 1
		IF sm% = 1 AND osm%<>sm% THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search mode:";CHR$(136);"[";CHR$(137);"constituency";CHR$(136);"]";CHR$(137);:?&7FBF=156
		IF sm% = 2 AND osm%<>sm% THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search mode:";CHR$(136);"[";CHR$(137);"   winner   ";CHR$(136);"]";CHR$(137);:?&7FBF=156
		IF sm% = 3 AND osm%<>sm% THEN PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);"Search mode:";CHR$(136);"[";CHR$(137);"    loser   ";CHR$(136);"]";CHR$(137);:?&7FBF=156
		osm% = sm%
	UNTIL INKEY(-74)
	REPEAT UNTIL NOT INKEY(-74)
	IF sm% = 1 THEN ss$=FNcustom_input ELSE ss$=FNsearch_party
	sc%=cc%
	IF sc% >= tc% THEN sc% = 0
	IF sc% = 0 THEN wp% = tc%-1 ELSE wp% = sc%-1
	PRINT TAB(0,21);CHR$(131);CHR$(157);CHR$(129);STRING$(33," ");:?&7FBF=156
	PRINT TAB(7,21);"Searching, please wait...";
	sr%=-1
	PROChide_cursor
	REPEAT
		IF sc% >= tc% THEN sc% = 0
		IF sm% = 1 AND INSTR(FNget_cons(sc%),ss$) THEN sr% = sc%
		IF sm% = 2 AND FNget_winner(sc%) = ss$ THEN sr% = sc%
		IF sm% = 3 AND FNget_loser(sc%) = ss$ THEN sr% = sc%
		IF sr% = -1 THEN sc% = sc% + 1
	UNTIL sc% = wp% OR sr% > -1
	IF sr% > -1 THEN PROCmove_cursor(sc%-cc%) ELSE PROCshow_cursor
	PROCshow_search_bar
ENDPROC

DEFPROCclear_search
	sm% = 0
	ss$ = ""
	sr% = 0
	PROCshow_search_bar
ENDPROC

DEFPROCmain_menu
	PROCshow_current_page
	ct%=0
	REPEAT
		IF INKEY(-114) THEN PROCshow_instructions:PROCshow_current_page
		IF INKEY(-1) THEN sp% = TRUE ELSE sp% = FALSE
		IF sp% THEN ma% = 19 ELSE ma% = 1
		IF INKEY(-116) AND NOT sp% THEN PROCsearch
		IF INKEY(-116) AND sp% THEN PROCclear_search
		IF INKEY(-58) THEN PROCmove_cursor(ma%*-1):ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF INKEY(-42) THEN PROCmove_cursor(ma%):ct%=TIME:REPEAT UNTIL TIME > ct%+25
		IF INKEY(-74) THEN PROCshow_constituency:PROCshow_current_page
	UNTIL FALSE
ENDPROC