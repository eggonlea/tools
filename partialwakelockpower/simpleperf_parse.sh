OUT=${1:-test.out}

cd $OUT
python3 $TOP/system/extras/simpleperf/scripts/binary_cache_builder.py -lib $ANDROID_PRODUCT_OUT/symbols
python3 $TOP/system/extras/simpleperf/scripts/pprof_proto_generator.py
python3 $TOP/system/extras/simpleperf/scripts/report_html.py

mkdir -p mydata
cp perf.data pprof.profile report.html mydata/

# pprof -http=:8080 pprof.profile
#
