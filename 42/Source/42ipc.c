#include "42.h"

//#ifdef __cplusplus
//namespace _42 {
//using namespace Kit;
//#endif
long Nmnem;
char **Mnemonic;
int Port,TxSocket,RxSocket;
FILE *RxStream;
char HostName[80];
long Echo;

/*********************************************************************/
/*********************************************************************/
/*********************************************************************/
void ReadStatesFromSocket(void)
{
      struct SCType *S;
      struct OrbitType *O;
      struct JointType *G;
      struct DynType *D;
      long IntVal1,IntVal2,IntVal3,IntVal4;
      double DblVal1,DblVal2,DblVal3,DblVal4;
      char line[512] = "Blank";
      char MnemString[80];
      long Isc;
      long RequestTimeRefresh = 0;
      long Done;
      char *LineIsValid;

      /* Default SC to apply inputs to */
      Isc = 0;
      while(!SC[Isc].Exists) Isc++;
      S = &SC[Isc];

      Done = 0;
      while(!Done) {
         LineIsValid = fgets(line,511,RxStream);
         if (Echo) printf("%s",line);
         if (LineIsValid == NULL) {
            Done = 1;
         }
         if (sscanf(line,"%s %ld-%ld-%ld:%ld:%lf",MnemString,
            &IntVal1,&IntVal2,&IntVal3,&IntVal4,&DblVal1) == 6) {
            if (!strcmp(MnemString,Mnemonic[MNEM_TIME])) {
               Year = IntVal1;
               doy = IntVal2;
               Hour = IntVal3;
               Minute = IntVal4;
               Second = DblVal1;
               RequestTimeRefresh = 1;
            }
         }
         if (sscanf(line,"%s %ld",MnemString,&IntVal1) == 2) {
            if (!strcmp(MnemString,Mnemonic[MNEM_SC])) {
               S = &SC[IntVal1];
               S->RequestStateRefresh = 0;
            }
         }
         if (sscanf(line,"%s %lf %lf %lf",MnemString,
            &DblVal1,&DblVal2,&DblVal3) == 4) {
            if (!strcmp(MnemString,Mnemonic[MNEM_POS])) {
               S->PosN[0] = DblVal1;
               S->PosN[1] = DblVal2;
               S->PosN[2] = DblVal3;
               S->RequestStateRefresh = 1;
            }
            if (!strcmp(MnemString,Mnemonic[MNEM_VEL])) {
               S->VelN[0] = DblVal1;
               S->VelN[1] = DblVal2;
               S->VelN[2] = DblVal3;
               S->RequestStateRefresh = 1;
            }
            if (!strcmp(MnemString,Mnemonic[MNEM_WBN])) {
               S->B[0].wn[0] = DblVal1;
               S->B[0].wn[1] = DblVal2;
               S->B[0].wn[2] = DblVal3;
               S->RequestStateRefresh = 1;
            }
            if (!strcmp(MnemString,Mnemonic[MNEM_SVB])) {
               S->FSW.svb[0] = DblVal1;
               S->FSW.svb[1] = DblVal2;
               S->FSW.svb[2] = DblVal3;
            }
            if (!strcmp(MnemString,Mnemonic[MNEM_BVB])) {
               S->FSW.bvb[0] = DblVal1;
               S->FSW.bvb[1] = DblVal2;
               S->FSW.bvb[2] = DblVal3;
            }
            if (!strcmp(MnemString,Mnemonic[MNEM_HVB])) {
               S->FSW.Hvb[0] = DblVal1;
               S->FSW.Hvb[1] = DblVal2;
               S->FSW.Hvb[2] = DblVal3;
            }
         }
         if (sscanf(line,"%s %lf %lf %lf %lf",MnemString,
            &DblVal1,&DblVal2,&DblVal3,&DblVal4) == 5) {
            if (!strcmp(MnemString,Mnemonic[MNEM_QBN])) {
               S->B[0].qn[0] = DblVal1;
               S->B[0].qn[1] = DblVal2;
               S->B[0].qn[2] = DblVal3;
               S->B[0].qn[3] = DblVal4;
               S->RequestStateRefresh = 1;
            }
         }
         if (sscanf(line,"%s %ld %lf %lf %lf",MnemString,
            &IntVal1,&DblVal1,&DblVal2,&DblVal3) == 5) {
            if (!strcmp(MnemString,Mnemonic[MNEM_GIM])) {
               G = &S->G[IntVal1];
               G->ang[0] = DblVal1;
               G->ang[1] = DblVal2;
               G->ang[2] = DblVal3;
               S->RequestStateRefresh = 1;
            }
         }
         if (sscanf(line,"%s %ld %lf",MnemString,
            &IntVal1,&DblVal1) == 3) {
            if (!strcmp(MnemString,Mnemonic[MNEM_HWHL])) {
               S->Whl[IntVal1].H = DblVal1;
            }
         }
         if (!strncmp(line,"[EOF]",5)) Done = 1;
      }
      /* Acknowledge receipt */
      fprintf(RxStream,"Ack\n");

/* .. Refresh time, SC states that depend on inputs */

      if (RequestTimeRefresh) {
         /* Update AbsTime, SimTime, etc */
         DOY2MD(Year,doy,&Month,&Day);
         AbsTime = DateToAbsTime(Year,Month,Day,Hour,Minute,Second);
         JulDay = AbsTimeToJD(AbsTime);
         SimTime = AbsTime-AbsTime0;
      }

      for(Isc=0;Isc<Nsc;Isc++) {
         if (SC[Isc].RequestStateRefresh) {
            S = &SC[Isc];
            S->RequestStateRefresh = 0;
            /* Update  RefOrb */
            O = &Orb[S->RefOrb];
            O->Epoch = AbsTime;
            RV2Eph(O->Epoch,O->mu,O->PosN,O->VelN,
               &O->SMA,&O->ecc,&O->inc,&O->RAAN,
               &O->ArgP,&O->anom,&O->tp,
               &O->SLR,&O->alpha,&O->rmin,
               &O->MeanMotion,&O->Period);
            FindCLN(O->PosN,O->VelN,O->CLN,O->wln);

            /* Update Dyn */
            MapJointStatesToStateVector(S);
            D = &S->Dyn;
            MapStateVectorToBodyStates(D->u,D->x,D->uf,D->xf,S);
            MotionConstraints(S);
         }
      }

}
/*********************************************************************/
void WriteStatesToSocket(void)
{
      struct SCType *S;
      struct JointType *G;
      struct WhlType *W;
      long Isc,Ig,Iw;
      char line[512];
      int Success = 0;

      sprintf(line,"%s  %ld-%ld-%ld:%ld:%lf\n",
         Mnemonic[MNEM_TIME],Year,doy,Hour,Minute,Second);
      Success = write(TxSocket,line,strlen(line));
      if (Echo) printf("%s",line);

      for(Isc=0;Isc<Nsc;Isc++) {
         S = &SC[Isc];
         sprintf(line,"%s %ld\n",
            Mnemonic[MNEM_SC], Isc);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_POS], S->PosN[0],S->PosN[1],S->PosN[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_VEL], S->VelN[0],S->VelN[1],S->VelN[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_WBN], S->B[0].wn[0],S->B[0].wn[1],S->B[0].wn[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le %le\n",
            Mnemonic[MNEM_QBN], S->B[0].qn[0],S->B[0].qn[1],
                                S->B[0].qn[2],S->B[0].qn[3]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_SVB], S->svb[0],S->svb[1],S->svb[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_BVB], S->bvb[0],S->bvb[1],S->bvb[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         sprintf(line,"%s  %le %le %le\n",
            Mnemonic[MNEM_HVB], S->Hvb[0],S->Hvb[1],S->Hvb[2]);
         Success = write(TxSocket,line,strlen(line));
         if (Echo) printf("%s",line);

         for(Ig=0;Ig<S->Ng;Ig++) {
            G = &S->G[Ig];
            sprintf(line,"%s  %ld %lf %lf %lf\n",
               Mnemonic[MNEM_GIM],Ig,G->ang[0],G->ang[1],G->ang[2]);
            Success = write(TxSocket,line,strlen(line));
            if (Echo) printf("%s",line);
         }

         for(Iw=0;Iw<S->Nw;Iw++) {
            W = &S->Whl[Iw];
            sprintf(line,"%s  %ld %lf\n",
               Mnemonic[MNEM_HWHL],Iw,W->H);
            Success = write(TxSocket,line,strlen(line));
            if (Echo) printf("%s",line);
         }
      }
      sprintf(line,"[EOF]\n\n");
      Success = write(TxSocket,line,strlen(line));
      if (Echo) printf("%s",line);

      /* Wait for ack */
      read(TxSocket,line,512);

}
/*********************************************************************/
void InitInterProcessComm(void)
{
      FILE *infile;
      char junk[120],newline,response[120];
      long Im;

      infile = FileOpen(InOutPath,"Inp_IPC.txt","rt");
      fscanf(infile,"%[^\n] %[\n]",junk,&newline);
      fscanf(infile,"%s %[^\n] %[\n]",response,junk,&newline);
      IpcMode = DecodeString(response);
      fscanf(infile,"%s %[^\n] %[\n]",response,junk,&newline);
      SocketRole = DecodeString(response);
      fscanf(infile,"%s %d %[^\n] %[\n]",HostName,&Port,junk,&newline);
      fscanf(infile,"%s %[^\n] %[\n]",response,junk,&newline);
      Echo = DecodeString(response);
      fscanf(infile,"%ld %[^\n] %[\n]",&Nmnem,junk,&newline);
      Mnemonic = (char **) calloc(Nmnem,sizeof(char *));
      for(Im=0;Im<Nmnem;Im++) {
         Mnemonic[Im] = (char *) calloc(40,sizeof(char));
      }
      fscanf(infile,"%[^\n] %[\n]",junk,&newline);
      fscanf(infile,"%[^\n] %[\n]",junk,&newline);
      for(Im=0;Im<Nmnem;Im++) {
         fscanf(infile,"%s %[^\n] %[\n]",Mnemonic[Im],junk,&newline);
      }
      fclose(infile);

      if (IpcMode == IPC_TX) {
         if (SocketRole == IPC_SERVER) {
            TxSocket = InitSocketServer(Port,TRUE);
         }
         else if (SocketRole == IPC_CLIENT) {
            TxSocket = InitSocketClient(HostName,Port,TRUE);
         }
         else {
            printf("Oops.  Unknown SocketRole %ld for TxSocket in InitInterProcessComm.  Bailing out.\n",SocketRole);
            exit(1);
         }
      }
      else if (IpcMode == IPC_RX) {
         if (SocketRole == IPC_SERVER) {
            RxSocket = InitSocketServer(Port,TRUE);
         }
         else if (SocketRole == IPC_CLIENT) {
            RxSocket = InitSocketClient(HostName,Port,TRUE);
         }
         else {
            printf("Oops.  Unknown SocketRole %ld for RxSocket in InitInterProcessComm.  Bailing out.\n",SocketRole);
            exit(1);
         }

         RxStream = fdopen(RxSocket,"r+");
      }
}
/*********************************************************************/
void InterProcessComm(void)
{
      if (IpcMode == IPC_TX) {
         WriteStatesToSocket();
      }
      else if (IpcMode == IPC_RX) {
         ReadStatesFromSocket();
      }
}

//#ifdef __cplusplus
//}
//#endif
