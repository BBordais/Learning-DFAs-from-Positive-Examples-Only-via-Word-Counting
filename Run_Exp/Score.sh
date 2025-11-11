i=8

#echo "Here is the summary of all the computations:"
File=Summary.py
echo "import numpy as np" > $File
for num_file in 02 05 06 08 15 17 21 24 27 28 #03 04 05 06 07 08 09 10 11 12 13 14 15 16 17 18 19 20 21 22 23 24 25 26 27 28
do
	if [ ${num_file} = 08 ]
	then
		i=7
	else
		i=8
	fi
	# Gathering the mean
	TimeSummary=Result/Result_Symbolic/Summary${num_file}/TimeSummary/Time_${num_file}_n_${i}
	if test -f $TimeSummary
	then
		echo -n "L_time_symbolic_${num_file} = [" >> $File
		count=$( grep -c -Eo '[0-9\.]+s e' $TimeSummary)
		countTimeout=$( grep -c -Eo 'Timeout' $TimeSummary)
		for j in `seq 1 $count`
		do
			grep -Eo '[0-9\.]+s e' $TimeSummary | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
			if [ $j = $count ] && [ $countTimeout = 0 ]
			then :
			else echo -n "," >> $File
			fi
		done
		for j in `seq 1 $countTimeout`
		do
			echo -n '1000' >> $File
			if [[ $j = $countTimeout ]]
			then :
			else echo -n "," >> $File
			fi
		done
		echo "]" >> $File
		echo "" >> $File
	fi
	echo "mean_${num_file} = np.mean(L_time_symbolic_${num_file})" >> $File
	
	TimeSummaryHeuristic=Result/Result_Heuristic_Approximation/Summary${num_file}/TimeSummary/Time_${num_file}_n_${i}
	echo -n "L_time_symbolic_heuristic_${num_file} = [" >> $File
	count=$( grep -c -Eo 'For approximation:' $TimeSummaryHeuristic)
	for j in `seq 1 $count`
	do
		Res=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/Res_${num_file}_n_${i}_test_${j}
		ResApp=Result/Result_Heuristic_Approximation/Summary${num_file}/DetailedSummary/ResApprox_${num_file}_n_${i}_test_${j}
		echo -n "(" >> $File
		grep -Eo 'DFA: [0-9\.]+s e|DFA: Timeout: 1000s' $TimeSummaryHeuristic | head -$j | tail -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
		echo -n "," >> $File
		grep -Eo 'score [0-9\.]+' $ResApp | head -1 | echo -n $(grep -Eo '[0-9\.]+') >> $File
		echo -n ")" >> $File
		if [ $j = $count ]
		then :
		else echo -n "," >> $File
		fi
	done
	echo "]" >> $File
	echo "L_performance_${num_file} = [(x[1],np.round(x[0]/mean_${num_file},3)) for x in L_time_symbolic_heuristic_${num_file}]" >> $File
done
#echo "print('Score','Time','Style')" >> $File
echo "L_heu_score=[]" >> $File
echo "L_heu_time=[]" >> $File
echo "L_score=[]" >> $File
echo "L_time=[]" >> $File
for num_file in 02 05 06 08 15 17 21 24 27 28
do
	echo "L_heu_score_${num_file} = []" >> $File
	echo "L_heu_time_${num_file} = []" >> $File
	echo "L_score_${num_file} = [(3**15-1)/2 for i in range(10)]" >> $File
	echo "L_time_${num_file} = L_time_symbolic_${num_file}" >> $File
	echo "with open('Score_${num_file}.dat','"'w'"') as f:" >> $File
	echo "    f.write('Time Score\n')" >> $File
	echo "    for i in range(len(L_performance_${num_file})):" >> $File
	echo "        L_heu_score_${num_file}.append(L_time_symbolic_heuristic_${num_file}[i][1])" >> $File
	echo "        L_heu_time_${num_file}.append(L_time_symbolic_heuristic_${num_file}[i][0])" >> $File
	echo "        s = str(L_performance_${num_file}[i][0]) + ' ' + str(L_performance_${num_file}[i][1]) + '\n'" >> $File
	echo "        f.write(s)" >> $File
	echo "    f.close()" >> $File
	echo "L_score_${num_file} += L_heu_score_${num_file}" >> $File
	echo "L_time_${num_file} += L_heu_time_${num_file}" >> $File
	echo "r_${num_file} = np.corrcoef(L_score_${num_file}, L_time_${num_file})" >> $File
	echo "print('The Pearson correlation coefficient for File ${num_file}:',np.round(r_${num_file}[0][1],3))" >> $File
	if [ ${num_file} = 08 ]
	then :
	else 
		echo "L_heu_score += L_heu_score_${num_file}" >> $File
		echo "L_heu_time += L_heu_time_${num_file}" >> $File
		echo "L_score += L_score_${num_file}" >> $File
		echo "L_time += L_time_${num_file}" >> $File
	fi
done
echo "r = np.corrcoef(L_score, L_time)" >> $File
echo "print('The total Pearson correlation coefficient:',np.round(r[0][1],3))" >> $File
echo "r = np.corrcoef(L_heu_score, L_heu_time)" >> $File
echo "print('The total Pearson correlation coefficient on normalized data:',np.round(r[0][1],3))" >> $File
python3 $File
rm -f $File


