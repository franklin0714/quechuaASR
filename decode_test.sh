#!/bin/bash
. ./cmd.sh || exit 1
. ./path.sh || exit 1
nj=1
# number of parallel jobs - 1 is perfect for such a small data set

#lm_order=2
# variables para dnn decoding
experiment_dir=exp/nnet2/nnet2_simple
unknown_phone=SPN 	   # having these explicit is just something I did when SPOKEN_NOISE
silence_phone=SIL          # I was debugging, they are now required by decode.sh
num_threads=1
# language model order (n-gram quantity) - 1 is enough for digits grammar

# Safety mechanism (possible running this script with modified arguments)
. utils/parse_options.sh || exit 1
#[[ $# -ge 1 ]] && { echo "Wrong arguments!"; exit 1; }

# Removing previously created data (from last run.sh execution)
sudo rm -rf data/test/spk2utt data/test/cmvn.scp data/test/feats.scp data/test/split* mfcc/cmvn_test.scp mfcc/cmvn_test.ark mfcc/raw_mfcc_test.1.ark mfcc/raw_mfcc_test.1.scp mfcc/raw_mfcc_test.2.ark mfcc/raw_mfcc_test.2.scp

echo
echo "===== PREPARING ACOUSTIC DATA ====="
echo
#Needs to be prepared by hand (or using self written scripts):
#
#spk2gender	[<speaker-id> <gender>]
#wav.scp	[<uterranceID> <full_path_to_audio_file>]
#text		[<uterranceID> <text_transcription>]
#utt2spk	[<uterranceID> <speakerID>]
#corpus.txt	[<text_transcription>]

# Making spk2utt files
#utils/utt2spk_to_spk2utt.pl data/train/utt2spk > data/train/spk2utt
utils/utt2spk_to_spk2utt.pl data/test/utt2spk > data/test/spk2utt
echo
echo "===== FEATURES EXTRACTION ====="
echo
# Making feats.scp files
mfccdir=mfcc
#utils/validate_data_dir.sh data/test
# script for checking if prepared data is all right
utils/fix_data_dir.sh data/test
# tool for data sorting if something goes wrong above
#steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/train exp/make_mfcc/train $mfccdir
steps/make_mfcc.sh --nj $nj --cmd "$train_cmd" data/test exp/make_mfcc/test $mfccdir
# Making cmvn.scp files
#steps/compute_cmvn_stats.sh data/train exp/make_mfcc/train $mfccdir
steps/compute_cmvn_stats.sh data/test exp/make_mfcc/test $mfccdir


echo
echo "===== PREPARING LANGUAGE DATA ====="
echo

# Needs to be prepared by hand (or using self written scripts):
#
# lexicon.txt				[<word> <phone 1> <phone 2> ...]
# nonsilence_phones.txt			[<phone>]
# silence_phones.txt 			[<phone>]
# optional_silence.txt			[<phone>]

# Preparing language data
#utils/prepare_lang.sh data/local/dict "<UNK>" data/local/lang data/lang


#echo
#echo "===== LANGUAGE MODEL CREATION ====="
#echo "===== MAKING lm.arpa ====="
#echo

#loc=`which ngram-count`;
#if [ -z $loc ]; then
#	if uname -a | grep 64 >/dev/null; then
#		echo "entro al primero+++++++++++++++++++++++++++++++"
#		sdir=$KALDI_ROOT/tools/srilm/bin/i686-m64
#	else
#		sdir=$KALDI_ROOT/tools/srilm/bin/i686
#	fi
#	if [ -f $sdir/ngram-count ]; then
#		echo "entro al segundo++++++++++++++++++++++++"
#		echo "Using SRILM language modelling tool from $sdir"
#		export PATH=$PATH:$sdir
#	else
#		echo "SRILM toolkit is probably not installed. Instructions: tools/install_srilm.sh"
#		exit 1
#	fi
#fi
#local=data/local
#mkdir $local/tmp
#ngram-count -order $lm_order -write-vocab $local/tmp/vocab-full.txt -wbdiscount -text $local/corpus.txt -lm $local/tmp/lm.arpa


#echo
#echo "===== MAKING G.fst ====="
#echo

#lang=data/lang
#cat $local/tmp/lm.arpa | arpa2fst - | fstprint | utils/eps2disambig.pl | utils/s2eps.pl | fstcompile --isymbols=$lang/words.txt --osymbols=$lang/words.txt --keep_isymbols=false --keep_osymbols=false | fstrmepsilon | fstarcsort --sort_type=ilabel > $lang/G.fst

#echo
#echo "===== MONO TRAINING ====="
#echo

#steps/train_mono.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono  || exit 1

#echo
#echo "===== MONO DECODING ====="
#echo

#utils/mkgraph.sh --mono data/lang exp/mono exp/mono/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/mono/graph data/test exp/mono/decode


echo 
echo "========DNN DECODING===="
echo

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
#echo
#echo "===== MONO ALIGNMENT =====" 
#echo

#steps/align_si.sh --nj $nj --cmd "$train_cmd" data/train data/lang exp/mono exp/mono_ali || exit 1

#echo
#echo "===== TRI1 (first triphone pass) TRAINING ====="
#echo

#steps/train_deltas.sh --cmd "$train_cmd" 2000 11000 data/train data/lang exp/mono_ali exp/tri1 || exit 1

#echo
#echo "===== TRI1 (first triphone pass) DECODING ====="
#echo

#utils/mkgraph.sh data/lang exp/tri1 exp/tri1/graph || exit 1
#steps/decode.sh --config conf/decode.config --nj $nj --cmd "$decode_cmd" exp/tri1/graph data/test exp/tri1/decode

echo
echo "===== run.sh script is finished ====="
echo
