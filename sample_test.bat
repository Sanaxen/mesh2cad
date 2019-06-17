:OBJファイル
:分割スムーズ度
:分割数目安	分割数目安
:曲面タイプ	type
:U方向セグメント
:V方向セグメント
:精度
:一時スケーリング
:生成IGES

del /Q iges\*.*
call mesh2cad bunny.obj 0.8 15 4 90 90 0.01 200
