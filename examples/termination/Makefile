SALLFILES=CPS.Double.fst       CPS.DoubleLambdaLifting.fst   CPS.Simple.fst\
	 CPS.DoubleCC.fst     CPS.DoubleLambdaLifting2.fst  CPS.SimpleDefun.fst\
	 CPS.DoubleDefun.fst  CPS.Expr.fst                  CPS.SimpleLambdaLifting.fst\
	 Eval.DB.fst	      Eval.DBCC.fst	            termination.fst
ALLFILES=wf.fst
FSTAR_HOME=../..
include ../Makefile.include

all: uall sall

uall: wf.uver

sall:$(SALLFILES)
	$(SFSTAR) $^
