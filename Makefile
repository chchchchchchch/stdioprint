190201_setup:
	./lib/mdsh/mk.sh E/190201_setup.mdsh pdf
190212_srccode:
	./lib/mdsh/mk.sh E/190212_srccode.mdsh pdf
190212_showios:
	./lib/mdsh/mk.sh E/190212_showios.mdsh pdf


instagram:
	utils/edit2www.sh --layers=0010 --crop=0000:0000:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012001001 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0010 --crop=1300:1300:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012001010 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0010 --crop=2600:1300:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012001012 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0010 --crop=3900:1300:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012001014 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0010 --crop=5200:1300:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012001016 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0020 --crop=0000:0000:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012002001 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0020 --crop=1300:0000:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012002002 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0020 --crop=2600:0000:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012002003 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0030 --crop=0000:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012003001 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0040 --crop=0000:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012004001 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0050 --crop=0000:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012005000 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0050 --crop=1300:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012005002 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0060 --crop=0000:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012006000 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0070 --crop=0000:0000:1080:1080    \
	                  --out=_/instagram --name=stdioio_2012007000 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0080 --crop=0000:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012008001 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0080 --crop=1300:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012008002 \
	                  --format=jpg E/201203_Dok.svg
	utils/edit2www.sh --layers=0080 --crop=2600:2600:1080:1350    \
	                  --out=_/instagram --name=stdioio_2012008003 \
	                  --format=jpg E/201203_Dok.svg

