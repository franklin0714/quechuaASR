#!/bin/bash

# Joshua Meyer 2017
# This script is based off the run_nnet2_baseline.sh script from the wsj eg
# This is very much a toy example, intended to be for learning the ropes of 
# nnet2 training and testing in Kaldi. You will not get state-of-the-art
# results.
# The default parameters here are in general low, to make training and 
# testing faster on a CPU.

stage=1
experiment_dir=exp/nnet2/nnet2_simple
num_threads=4
minibatch_size=128
unknown_phone=SPN 	   # having these explicit is just something I did when SPOKEN_NOISE
silence_phone=SIL          # I was debugging, they are now required by decode.sh

. ./path.sh
. ./utils/parse_options.sh

for nodos in 400 512; do
		if [ $stage -le 1 ]; then

		    echo ""
		    echo "######################"
		    echo "### BEGIN TRAINING ###"
		    echo "### entrenando con capa: 3 y nodos: $nodos  #### "
		    echo "######################"

		    mkdir -p $experiment_dir

		    steps/nnet2/train_simple.sh \
			--stage -10 \
			--num-threads "$num_threads" \
			--feat-type raw \
			--splice-width 4 \
			--lda_dim 40 \
			--num-hidden-layers 3 \
			--hidden-layer-dim "$nodos" \
			--add-layers-period 2 \
			--num-epochs 10 \
			--iters-per-epoch 1 \
			--initial-learning-rate 0.02 \
			--final-learning-rate 0.004 \
			--minibatch-size "$minibatch_size" \
			data/train \
			data/lang \
			exp/tri1_ali \
			$experiment_dir \
			|| exit 1;

		    echo ""
		    echo "####################"
		    echo "### END TRAINING ###"
		    echo "####################"

		fi

		if [ $stage -le 2 ]; then

		    echo ""
		    echo "#####################"
		    echo "### BEGIN TESTING ###"
		    echo "#####################"

		    steps/nnet2/decode_simple.sh \
			--num-threads "$num_threads" \
			--beam 8 \
			--max-active 500 \
			--lattice-beam 3 \
			exp/tri1/graph \
			data/test \
			$experiment_dir/final.mdl \
			$unknown_phone \
			$silence_phone \
			$experiment_dir/decode \
			|| exit 1;

		    for x in ${experiment_dir}/decode*; do
			[ -d $x ] && grep WER $x/wer_* | \
			    utils/best_wer.sh > nnet2_simple_wer.txt;
		    done

		    echo ""
		    echo "###################"
		    echo "### END TESTING ###"
		    echo "###################"

		fi
	done;
