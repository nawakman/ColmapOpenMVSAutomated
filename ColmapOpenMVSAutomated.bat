::documentation: https://github.com/mwtarnowski/colmap-parameters
::Before running this script please create an empty database in Colmap installation folder (next to COLMAP.bat) via Colmap GUI>newProject

::These parameters are specific to computer 

::Store current Directory: 
set currDir=%CD% 
mkdir model

:: Set colmap directory:
set colDir=D:\Softwares\photogrammetry\COLMAP-3.8-windows-cuda\COLMAP.bat

:: Set openMVS directory
set oMVS=D:\Softwares\photogrammetry\OpenMVS_Windows_x64

:: Set Working Directory (windows)
set workDir="D:\photogrammetryOutput"

mkdir %workDir%\images
copy *.jpg %workDir%\images
copy *.png %workDir%\images

:: Copy database.db from Colmap Folder (see line 2 of this script)
copy %colDir%\..\database.db %workDir%\

cd /d %workDir%

call %colDir% feature_extractor --database_path database.db --image_path images
call %colDir% exhaustive_matcher --database_path database.db
mkdir sparse
call %colDir% mapper --database_path database.db --image_path images --output_path sparse
call %colDir% model_converter --input_path sparse\0 --output_path model.nvm --output_type NVM
mkdir dense
call %colDir% image_undistorter --image_path images --input_path sparse\0 --output_path dense
call %oMVS%\InterfaceCOLMAP.exe dense -o model.mvs
call %oMVS%\DensifyPointCloud.exe model.mvs
call %oMVS%\ReconstructMesh.exe model_dense.mvs
call %oMVS%\RefineMesh.exe --resolution-level 1 model_dense_mesh.mvs
call %oMVS%\TextureMesh.exe --export-type obj model_dense_mesh_refine.mvs

copy *.obj %currDir%\model
copy *.mtl %currDir%\model
copy *.png %currDir%\model

::Uncomment these lines in to delete working directory
::cd /d %currDir%
::RD /S /Q %workDir%

@pause