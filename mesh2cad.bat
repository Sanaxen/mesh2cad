:OBJファイル
:分割スムーズ度
:分割数目安	分割数目安
:曲面タイプ	type
:U方向セグメント
:V方向セグメント
:精度
:一時スケーリング
:生成IGES



set tmp_id=%RANDOM%
copy %1 work\%tmp_id%.obj /v /y

cd work
set tmp_dir=%CD%\tmp

mkdir error_file
mkdir segment_file
mkdir uvmapping
mkdir boundary
del /Q error_file\*.*
del /Q segment_file\*.*
del /Q uvmapping\*.*
del /Q boundary\*.*
copy ..\bin\checker_1k.bmp uvmapping /v /y
:pause

set cadtype=%4
set upatch=%5
set vpatch=%6

del  OutputParams.txt

for %%i in ( %tmp_id%_Segment_* ) do (
	del "%%i"
)
..\bin\aut_segmentation.exe %tmp_id%.obj -lambda %2 -clusters %3

:	pause
for %%i in ( %tmp_id%_Segment_* ) do (
	if exist %%i.obj (
		..\bin\ParameterizeMeshSolver.exe -input %%i.obj -stretch 0.7  -mesh^(%upatch%,%vpatch%^) -scale %8
		if exist %%i_out.obj (
			..\bin\meshToSurf %%i_out.obj -o %%i_cp.dat -t %cadtype% -p %upatch% %vpatch% -tol %7
			..\bin\igescnv_write.exe %%i_cp.dat -o %%i.iges
			copy %%i_parameter_mesh.obj uvmapping /v /y
			copy %%i_parameter_mesh.obj.mtl uvmapping /v /y
			copy %%i_boundary.obj boundary /v /y
			copy %%i.obj "%tmp_dir%" /v /y
			copy %%i.mtl "%tmp_dir%" /v /y
			del %%i.obj
			del %%i.mtl
REM				echo ImportFile="%tmp_dir%\%%i.obj" >> OutputParams.txt
		) else (
			copy %%i.off error_file /v /y
			copy NonManifold_edge.obj error_file\NonManifold_%%i.obj /v /y
		)
	)
)

:pause
del /Q *_parameter_mesh.obj
del /Q *_parameter_mesh.obj.mtl
del /Q *_out.obj
del /Q *_out.obj.mtl
del /Q *_in.obj
del /Q *_in.obj.mtl
del /Q *_cp.dat
del /Q *_boundary.obj
del /Q *_wrk.obj

:1
	
:pause	
for %%i in ( %tmp_id%_Segment_*.iges ) do (
	if "%9"=="" (
		echo 
	) else (
		copy %%i "%9" /v /y
	)
	copy %%i ..\iges /v /y
)
echo IGESファイルを > message.txt
if "%9"=="" (
	echo  [iges]に作成しました >> message.txt
) else (
	echo  [%9]に作成しました >> message.txt
)
echo ============================= >> message.txt
type message_tmp.txt >> message.txt

:pause



if exit error_file\NonManifold*.obj (
	type message_tmp.txt >> message.txt
	dir /B error_file >>  message.txt
	echo "Non Manifold mesh!!" >> message.txt
	echo "Non Manifold mesh!!" > %input%.log
	.\bin\message message.txt
)

cd ..

