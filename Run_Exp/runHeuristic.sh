# Number of states
n=8
# Maximal word length considered (for counting purposes), heuristic algorithm only
h=14
# Number of attempt to initialize a transition system, heuristic algorithm only
InitRand=100
# Number of runs, heuristic algorithm only
NbRun=50
# The Traces file considered
num_file=29
echo ""
echo "Start heuristic approximation for file ${num_file} for n = ${n}"
for j in `seq 1 10`
do
	echo "Start test = ${j}"
	startDFA=Result/Result_Heuristic_Approximation/Summary${num_file}/DFAs/Start_dfa_${num_file}_n_${n}_test_${j}.dot
	Trace=Traces/Traces${num_file}.words
	DFA=Result/Result_Heuristic_Approximation/Summary${num_file}/DFAs/dfa${num_file}_n_${n}_test_${j}.dot
	ResApp=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/ResApprox_${num_file}_n_${n}_test_${j}
	Res=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/Res_${num_file}_n_${n}_test_${j}
	TimeSummary=Result/Result_Heuristic_Approximation/Summary${num_file}/TimeSummary/Time_${num_file}_n_${n}

	./Heuristic_Approximation/main "${Trace}" "${startDFA}" "${n}" "${h}" "${InitRand}" "${NbRun}" > ${ResApp};
	echo "Done with approximation";
	timeout 1000 ./Symbolic/infer --log=INFO -o "stats.json" specific DFA -f ${Trace} --dfa=${DFA} --dfa-starting=${startDFA} -n=${n} --method=SYMB 2> ${Res};
	
	#step=$( grep -c -Eo 'found new dfa:' $Res) + 1 
	echo -n "For approximation: " >> ${TimeSummary}
	grep -Eo '[0-9\.]+s elapsed' ${ResApp} >> ${TimeSummary}
	echo -n "For solving from starting DFA: " >> ${TimeSummary}
	if grep -q -s -Eo '[0-9\.]+s elapsed' ${Res} 
	then 
		grep -Eo '[0-9\.]+s elapsed' ${Res} >> ${TimeSummary}
		if grep -q -Eo 'DFA found in: [0-9\.]+s' ${Res} 
		then 
			grep -Eo 'DFA found in: [0-9\.]+s' ${Res} | tail -1 >> ${TimeSummary}
		else 
			echo "The starting DFA worked!" >> ${TimeSummary}
		fi
	else 
		echo "Timeout: 1000s" >> ${TimeSummary}
	fi	
	#echo -n "Number of steps from starting DFA: ${step}" >> ${TimeSummary}
	#I will write this as a gather approx, to be uniform with the symbolic case.
	echo "" >> ${TimeSummary}
	echo ""
	echo "Done with test = ${j}"
done
