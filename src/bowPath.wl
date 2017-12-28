(* ::Package:: *)

bowPath[data_]:=Module[{title,tIndex,tData,changeStringControlAngle,stringname,tAccumulateData,lIndex,lDataPrep,lDataPrep1,lData,lengthFunction,sIndex,sData,nIndex,nData,rootMargin,n,d,bAng,bowAngle,aData,angleData,lengthData,angleFunction,path,speed,noteTextPrep,noteTextCoordinate,lDirection,stringplot,pathplot,angleplot,angleData2,angleData3,tc,angleTurnPre,angleTurnNow,stringangle,p2},
(*data section*)
(*import data*)
(*title of data*)
title=data[[1]];
(*re-oganize data*)
(*n: indication of notes;
t: time spent [t accumulate is time axis];
s: string [G:4, D:3, A:2, E:1] for violin, count from right to left starting from 1;
l: position of bow [root:0, end:1]*)
tIndex=First@First@Position[title,"t"];
tData=data[[2;;,tIndex]];
tAccumulateData=Accumulate[tData];
lIndex=First@First@Position[title,"l"];
lDataPrep=data[[2;;,lIndex]];
lDataPrep1=Table[If[lDataPrep[[i]]!="",{tAccumulateData[[i]],lDataPrep[[i]]},{}],{i,Length[lDataPrep]}];
lDataPrep1=DeleteCases[lDataPrep1,{}];
PrependTo[lDataPrep1,{0,lDataPrep1[[1,2]]}];
AppendTo[lDataPrep1,{lDataPrep1[[-1,1]]+1,lDataPrep1[[-1,2]]}];
lengthFunction=Interpolation[lDataPrep1, Method->"Spline",InterpolationOrder->2];
lData=Table[lengthFunction[tAccumulateData[[i]]],{i,Length[lDataPrep]}];
sIndex=First@First@Position[title,"s"];
sData=data[[2;;,sIndex]];
(*if no indication, set to empty*)
If[Position[title,"n"]!={},nIndex=First@First@Position[title,"n"];
nData=data[[2;;,nIndex]];,nData=Table["",{i,Length[lData]}]];
(*initilize system parameters*)
rootMargin=0.1;
(*sample points*)n=40;
(*length division*)d=4;
(*change string time [*]<1*)tc=0.5;
(*second deirivitive peak percentage*)p2=.3;
(*string name*)stringname={"G","D","A","E"};
(*(*viola*)stringname={"C","G","D","A"};*)(*(*cello*)stringname={"A","D","G","C"};*)(*(*bass*)stringname={"E","A","D","G"};*)(*(*Cello da spalla*)stringname={"C","G","D","A","E"};*)
(*string angle: 40 degree total for string instruments*)stringangle=40;
stringangle/=Length[stringname];
(*bow angle: degree*)
bAng=-Table[(i-.5(Length[stringname]-1))*stringangle,{i,0,Length[stringname]-1}];
(*changing angle of strings*)changeStringControlAngle=Reverse[Table[bAng[[i-1]]+bAng[[i]],{i,2,Length[bAng]}]/2];
bowAngle=Table[i->Reverse[bAng][[i]],{i,Length[bAng]}];
aData=sData/.bowAngle;
angleData={{tAccumulateData[[1]],aData[[1]]}};
(*1st derivitive control points*)
Do[AppendTo[angleData,{tAccumulateData[[i]],Which[aData[[i]]-aData[[i-1]]<0,changeStringControlAngle[[sData[[i]]]],aData[[i]]-aData[[i-1]]>0,changeStringControlAngle[[sData[[i]]-1]],True,aData[[i]]]}],{i,2,Length[tAccumulateData]}];
angleData2=angleData;
(*2nd derivitive control points*)
Do[If[(aData[[i]]-aData[[i-1]])*(aData[[i+1]]-aData[[i]])<0,AppendTo[angleData2,{(tAccumulateData[[i]]+tAccumulateData[[i+1]])/2,angleData[[i,2]]+Sign[aData[[i]]-aData[[i-1]]]*p2*stringangle}]],{i,2,Length[tAccumulateData]-1}];
angleData2=Sort[angleData2];
angleFunction=Interpolation[angleData2,Method->"Spline",InterpolationOrder->2];(*plot section*)
(*string plot*)
angleData3=Table[{t,angleFunction[t]},{t,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
stringplot=Show[{ListLinePlot[angleData3,PlotStyle->Directive[Gray,Dashed],PlotRange->All],Graphics[Flatten@{Black,Table[Text[nData[[i]],angleData[[i]],Background->White],{i,1,Length[nData]}]}]},Frame->True,AspectRatio->1/4,FrameLabel->{"t","angle"},ImageSize->800];
(*bow angle plot*)
lengthData=Table[{t*1.,lengthFunction[t]},{t,tAccumulateData[[1]],tAccumulateData[[-1]],1/n}];
angleplot=Show[{ListLinePlot[lengthData, PlotStyle -> Directive[Gray, Dashed],PlotRange->All],Graphics[Flatten@{Black,Dashing[None],Table[Text[nData[[i]],{tAccumulateData[[i]],lData[[i]]},Background->White],{i,1,Length[nData]}]},PlotRange->All]},Frame->True,AspectRatio->1/4,FrameLabel->{"t","bow position"},ImageSize->800];
(*plot path*)
path=Table[{x*1.,(lengthFunction[x]+rootMargin)*{Cos[angleFunction[x]*\[Pi]/360],Sin[angleFunction[x]*\[Pi]/360]}},{x,1,tAccumulateData[[-1]],1/n}];
speed=Norm/@Differences[path[[;;,2]]];speed/=Max[speed];
noteTextPrep={Transpose[angleData][[-1]],lData};
noteTextCoordinate=Table[(rootMargin+noteTextPrep[[2,i]])*{Cos[noteTextPrep[[1,i]]*\[Pi]/360],Sin[noteTextPrep[[1,i]]*\[Pi]/360]},{i,Length[tData]}];
lDirection=Differences[Append[lData,0]];
(*plot bow path*)
pathplot=Show[Flatten@{(*show initial point*)Graphics[Flatten@{GrayLevel[.97],Table[{PointSize[.07*1.3^(-i*20/n)],Point[path[[i,2]]]},{i,If[Length[path]>n/2,n/2,Length[path]]}]}],
(*string angle*)Table[ListLinePlot[{0.8*rootMargin*{Cos[\[Pi]/360*changeStringControlAngle[[i]]],Sin[\[Pi]/360*changeStringControlAngle[[i]]]},(1.02+rootMargin) {Cos[\[Pi]/360*changeStringControlAngle[[i]]],Sin[\[Pi]/360*changeStringControlAngle[[i]]]}},PlotStyle->Directive[LightGray,Dashed]],{i,Length[changeStringControlAngle]}],Graphics[{LightGray,Table[Style[Text[stringname[[i]],(.9*rootMargin) {Cos[\[Pi]/360*bAng[[i]]],Sin[\[Pi]/360*bAng[[i]]]}],16],{i,Length[bAng]}]}],
(*bow length*)Graphics[Flatten@{Dashed,LightGray,Table[Circle[{0,0},rootMargin+i/d,{-(Max[bAng]+1)*\[Pi]/360,(Max[bAng]+1)*\[Pi]/360}],{i,1,d-1}],Gray,Table[Circle[{0,0},rootMargin+i/d,{-(Max[bAng]+1)*\[Pi]/360,(Max[bAng]+1)*\[Pi]/360}],{i,{0,d}}]}],Graphics[{LightGray,Table[Style[Text[ToString[InputForm[(i-1)/d]],((i-1)/d+rootMargin) {Cos[\[Pi]/360*(Max[bAng]+1)],If[OddQ[i],1,-1]*Sin[\[Pi]/360*(Max[bAng]+1)]}+{0,If[OddQ[i],1,-1]*0.005}],16],{i,1,d+1}]}],
(*Path*)Graphics[Flatten@{Opacity[If[Length[tData]>30,.4,.8]],Thick,Table[{ColorData["Rainbow"][speed[[i]]],Line[{path[[i,2]],path[[i+1,2]]}]},{i,Length[speed]}]}],
(*time*)If[Length[tData]>30,{},Graphics[Flatten@{Table[Style[Text[ToString[tAccumulateData[[i]]]<>If[nData[[i]]=="","",":"]<>nData[[i]],noteTextCoordinate[[i]]+RandomReal[.01{-1,1},2]],Italic,If[lDirection[[i]]>0,Red,Blue],Background->White],{i,Length[nData]}]}]]},PlotRange->All,Axes->False,ImageSize->1600,AspectRatio->1];Column[{pathplot,Row[{stringplot,angleplot}]},Frame->True]];
