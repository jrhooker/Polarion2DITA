set PATHTOSERVER=https://polarion.microchip.com/polarion/#/project/
set PROJECT-NAME=AVR_SD
set PATHTOPROJECT=Source\Technical_Safety_Concept-r169624
set FILENAME=module.xml
set DITAMAPNAME=Technical_Safety_Concept-r169624.ditamap
cd ..\

set WORKINGDIR=%CD%

cd %WORKINGDIR%\batchfiles

rd /s /q %WORKINGDIR%\in\

rd /s /q %WORKINGDIR%\out\

mkdir %WORKINGDIR%\out\

mkdir %WORKINGDIR%\in\

mkdir %WORKINGDIR%\out\attachments

xcopy %WORKINGDIR%\%PATHTOPROJECT%\attachments\* %WORKINGDIR%\out\attachments\*

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step1.xml "%WORKINGDIR%\%PATHTOPROJECT%\%FILENAME%" %WORKINGDIR%\depend\custom\step1.xsl

echo Step 1 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h1.xml %WORKINGDIR%\in\step1.xml %WORKINGDIR%\depend\custom\step2-h1.xsl

echo Step 2 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h2.xml %WORKINGDIR%\in\step2-h1.xml %WORKINGDIR%\depend\custom\step2-h2.xsl

echo Step 3 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h3.xml %WORKINGDIR%\in\step2-h2.xml %WORKINGDIR%\depend\custom\step2-h3.xsl 

echo Step 4 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h4.xml %WORKINGDIR%\in\step2-h3.xml %WORKINGDIR%\depend\custom\step2-h4.xsl 

echo Step 5 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h5.xml %WORKINGDIR%\in\step2-h4.xml %WORKINGDIR%\depend\custom\step2-h5.xsl 

echo Step 6 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step2-h6.xml %WORKINGDIR%\in\step2-h5.xml %WORKINGDIR%\depend\custom\step2-h6.xsl 

echo Step 7 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step4.xml %WORKINGDIR%\in\step2-h6.xml %WORKINGDIR%\depend\custom\integrate-object-data.xsl pathtoproject="%WORKINGDIR%\%PATHTOPROJECT%" project-name="%PROJECT-NAME%" pathtoserver="%PATHTOSERVER%"

echo Step 8 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar -o:%WORKINGDIR%\in\step5.xml %WORKINGDIR%\in\step4.xml %WORKINGDIR%\depend\custom\unique-ids.xsl

echo Step 9 complete

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar   -o:%WORKINGDIR%\out\%DITAMAPNAME% %WORKINGDIR%\in\step5.xml %WORKINGDIR%\depend\custom\generate_bookmap.xsl

echo Bookmap Generated

java -jar %WORKINGDIR%\saxonhe9-3-0-4j\saxon9he.jar   -o:%WORKINGDIR%\out\trashme.xml %WORKINGDIR%\in\step5.xml %WORKINGDIR%\depend\custom\generate_topics.xsl

echo Topics Generated

cd %WORKINGDIR%\batchfiles