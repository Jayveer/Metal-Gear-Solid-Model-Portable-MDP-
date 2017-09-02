-- made by Jayveer for savemgo.com
-- if you are interested in reversing Metal Gear Solid games join our discord 
-- https://discord.gg/rKRVz76

clearlistener()

fn colourMesh mesh = (
	mesh.wirecolor =  color (random 0 255) (random 0 255) (random 0 255)
)

fn scaleToBoundingBox maxmsh gamemsh = (
	if (gamemsh.maxX != 0) then (
		maxmsh.scale *= (gamemsh.maxX / maxmsh.max.x)
	) else (
		maxmsh.scale *= (gamemsh.minX / maxmsh.min.x)
	)	
)

fn getMatIdFromName matName mat = (
	matId = 0
	for m = 1 to mat.materialList.count do (
		if ((bit.intAsHex(matName)) == mat.materialList[m].name) then (
			matId = m
		)
	)
	return matId
)

fsource = GetOpenFileName \
caption:"Select mdn File" \
types: "Model Portable(*.mdp)|*.mdp|All files (*.*)|*.*|"
if fsource != undefined then (
f = fopen fsource "rb"


vertexBuffer =#()
faceBuffer =#()
uvBuffer = #()
normalBuffer = #()
materialBuffer = #()
colourBuffer =#()
weightBuffer =#()
tempVertexBuffer = #()
tempFaceBuffer = #()
tempUvBuffer =#()
tempNormalBuffer = #()
tempMaterialBuffer = #()
tempWeightBuffer =#()
tempColourBuffer =#()
boneBuffer =#()
bonePalletBuffer =#()
	
struct header
(
	magic,
	boneCount,
	groupCount,
	objectCount,
	fileName,
	boneIndexOffset,
	groupIndexOffset,
	objectIndexOffset,
	unknown,
	nullBytes2,
	nullBytes3,
	nullBytes4,
	maxX,
	maxY,
	maxZ,
	maxW,
	minX,
	minY,
	minZ,
	minW
)

struct boneIndex 
(
	hashName,
	y0,
	parent,
	w0,
	rotX,
	rotY,
	rotZ,
	rotW,
	posX,
	posY,
	posZ,
	posW,
	maxX,
	maxY,
	maxZ,
	maxW,
	minX,
	minY,
	minZ,
	minW
)

struct groupIndex 
(
	hashedName,
	unknown,
	parent,
	nullBytes
)

struct objectIndex
(
	hashedName,
	flag,
	flag2,
	unknown,
	faceIndexCount,
	faceIndexOffset,
	vertexBufferOffset,
	bonePalletOffset,
	vertexBufferCount,
	nullBytes,
	maxX,
	maxY,
	maxZ,
	maxW,
	minX,
	minY,
	minZ,
	minW,
	posX,
	posY,
	posZ,
	posW	
)

struct faceIndex
(
	unknown,
	faceBufferSize,
	faceBufferOffset,
	nullBytes,
	matIndexOffset,
	nullBytes2
)

struct matIndex
(
	hashedName,
	unknown,
	unknown2,
	unknown3,
	unknown4,
	r,
	g,
	b,
	specularPower
)

struct bonePallet
(
	hashedName ,
	boneCount,
	boneid
)

struct vBuffer
(
	tu,
	tv,
	r,
	g,
	b,
	a,
	nX,
	nY,
	nZ,
	vX,
	vY,
	vZ
)

struct fBuffer
(
	fa,
	fb,
	fc
)

-------------------header--------------------------
mdpHeader = header()

mdpHeader.magic = readlong f
mdpHeader.boneCount = readlong f
mdpHeader.groupCount = readlong f
mdpHeader.objectCount = readlong f
mdpHeader.fileName = readlong f
mdpHeader.boneIndexOffset = readlong f
mdpHeader.groupIndexOffset = readlong f
mdpHeader.objectIndexOffset = readlong f
mdpHeader.unknown = readlong f
mdpHeader.nullBytes2 = readlong f
mdpHeader.nullBytes3 = readlong f
mdpHeader.nullBytes4 = readlong f
mdpHeader.maxX = readfloat f
mdpHeader.maxY = readfloat f
mdpHeader.maxZ = readfloat f
mdpHeader.maxW = readfloat f
mdpHeader.minX = readfloat f
mdpHeader.minY = readfloat f
mdpHeader.minZ = readfloat f
mdpHeader.minW = readfloat f


----------------boneindex-----------------------------------

fseek f mdpHeader.boneIndexOffset #seek_set

if mdpHeader.boneCount !=0 then (
	for i = 1 to mdpHeader.boneCount do (
		boneIdx = boneIndex()
		boneIdx.hashName = readlong f
		boneIdx.y0 = readlong f
		boneIdx.parent  = readlong f + 1
		boneIdx.w0  = readlong f
		boneIdx.rotX = readfloat f
		boneIdx.rotY = readfloat f
		boneIdx.rotZ  = readfloat f
		boneIdx.rotW  = readfloat f
		boneIdx.posX  = readfloat f
		boneIdx.posY  = readfloat f
		boneIdx.posZ = readfloat f
		boneIdx.posW = readfloat f
		boneIdx.maxX  = readfloat f
		boneIdx.maxY  = readfloat f
		boneIdx.maxZ  = readfloat f
		boneIdx.maxW  = readfloat f
		boneIdx.minX  = readfloat f
		boneIdx.minY  = readfloat f
		boneIdx.minZ  = readfloat f
		boneIdx.minW = readfloat f

		append boneBuffer boneIdx

	)
	
	for i = 1 to mdpHeader.boneCount do (
		rx =	boneBuffer[i].rotX;	 ry = boneBuffer[i].rotY; 		rz = boneBuffer[i].rotZ; 	 rw = boneBuffer[i].rotW
		px =	boneBuffer[i].posX; 	 py = boneBuffer[i].posY;		pz = boneBuffer[i].posZ;	 pw = boneBuffer[i].posW
		sx =	boneBuffer[i].maxX;	 sy = boneBuffer[i].maxY; 		sz = boneBuffer[i].maxZ;	 sw = boneBuffer[i].maxW
		qx =	boneBuffer[i].minX;	 qy = boneBuffer[i].minY; 		qz = boneBuffer[i].minZ;	 qw = boneBuffer[i].minW
		
		BoneRot = (quat rw rx ry rz) as matrix3
		BonePos = [px,py,pz, pw]

		bne = dummy showLinks:true showLinksOnly:true
		bne.name = (bit.IntAsHex(boneBuffer[i].hashName) as string)
		bne.rotation = BoneRot
		bne.pos = BonePos
		--scaleToBoundingBox bne boneBuffer[i]
		
		if (boneBuffer[i].parent  != 0) then bne.parent = getNodeByName (bit.IntAsHex(boneBuffer[(boneBuffer[i].parent)].hashName) as string)
		
	)
)

-----------------groupindex--------------------

fseek f mdpHeader.groupIndexOffset #seek_set

mdpGroupIndexArray = #()

for i = 1 to mdpHeader.groupCount do
(
	mdpGroupIndex = groupIndex()
	mdpGroupIndex.hashedName = readlong f
	mdpGroupIndex.unknown = readlong f
	mdpGroupIndex.parent = readlong f + 1
	mdpGroupIndex.nullBytes = readlong f
	
	append mdpGroupIndexArray mdpGroupIndex
)

for i = 1 to mdpHeader.groupCount do (
		layer = LayerManager.newLayer()
		layer.setname (bit.intAsHex(mdpGroupIndexArray[i].hashedName) as string)
	if (mdpGroupIndexArray[i].parent != 0) then (
		parentLayer = LayerManager.getLayerFromName ((bit.intAsHex(mdpGroupIndexArray[(mdpGroupIndexArray[i].parent)].hashedName) as string))
		layer.setParent parentLayer 
	) 
)
-----------------objectindex--------------------

fseek f mdpHeader.objectIndexOffset #seek_set

mdpObjectIndexArray = #()

for i = 1 to mdpHeader.objectCount do
(
	mdpObjectIndex = objectIndex()
	
	mdpObjectIndex.hashedName = readlong f
	mdpObjectIndex.flag = readbyte f
	mdpObjectIndex.flag2 = readbyte f
	mdpObjectIndex.unknown = readshort f
	mdpObjectIndex.faceIndexCount = readlong f
	mdpObjectIndex.faceIndexOffset = readlong f
	mdpObjectIndex.vertexBufferOffset = readlong f
	mdpObjectIndex.bonePalletOffset = readlong f
	mdpObjectIndex.vertexBufferCount = readlong f
	mdpObjectIndex.nullBytes = readlong f
	mdpObjectIndex.maxX = readfloat f
	mdpObjectIndex.maxY = readfloat f
	mdpObjectIndex.maxZ = readfloat f
	mdpObjectIndex.maxW = readfloat f
	mdpObjectIndex.minX = readfloat f
	mdpObjectIndex.minY = readfloat f
	mdpObjectIndex.minZ = readfloat f
	mdpObjectIndex.minW = readfloat f
	mdpObjectIndex.posX = readfloat f
	mdpObjectIndex.posY = readfloat f
	mdpObjectIndex.posZ = readfloat f
	mdpObjectIndex.posW = readfloat f
	
	append mdpObjectIndexArray mdpObjectIndex
)

-----------------faceindex---------------------

mdpFaceIndexArray = #()

for i = 1 to mdpHeader.objectCount do
(		
	fseek f mdpObjectIndexArray[i].faceIndexOffset #seek_set
	
	mdpFaceIndexArray2 = #()
	
	for j = 1 to mdpObjectIndexArray[i].faceIndexCount do 
	(
		mdpFaceIndex = faceIndex()
		
		mdpFaceIndex.unknown = readshort f #unsigned
		mdpFaceIndex.faceBufferSize = readshort f #unsigned
		mdpFaceIndex.faceBufferOffset = readlong f #unsigned
		mdpFaceIndex.matIndexOffset = readlong f #unsigned
		
		append mdpFaceIndexArray2 mdpFaceIndex
	)
	
	append mdpFaceIndexArray mdpFaceIndexArray2
	
)

---------materialindex---------------------------------


for i = 1 to mdpHeader.objectCount do
(	
	for j = 1 to mdpObjectIndexArray[i].faceIndexCount do (
		fseek f mdpFaceIndexArray[i][j].matIndexOffset #seek_set
		
		matName  = readlong f
		makeMaterial  = true
		
		for m =1 to materialBuffer.count do (
			if (matName == materialBuffer[m].hashedName) then (
				makeMaterial = false
			)
		)
		
		if (makeMaterial == true) then (
			materialIndex = matIndex()
			materialIndex.hashedName = matName
			materialIndex.unknown = readbyte f
			materialIndex.unknown2 = readbyte f
			materialIndex.unknown3 = readbyte f
			materialIndex.unknown4 = readbyte f
			materialIndex.r = readlong f *-255
			materialIndex.g = readlong f * -255
			materialIndex.b = readlong f * -255
			materialIndex.specularPower = readfloat f
			
			append materialBuffer materialIndex
		)		
	)
)

mat = multimaterial numsubs: (materialBuffer.count)
for i = 1 to materialBuffer.count do (
	mat[i] = StandardMaterial name:(bit.intAsHex(materialBuffer[i].hashedName) as string)
	mat[i].diffuseMap = Bitmaptexture fileName:(sysInfo.currentdir + "\\textures\\" + (bit.intAsHex(materialBuffer[i].hashedName) as string) + ".tga")
	mat[i].specularLevel = materialBuffer[i].specularPower
	mat[i].Diffuse = color materialBuffer[i].r materialBuffer[i].g materialBuffer[i].b
	mat[i].showInViewPort = on
)

mat.materialList.count 

--------bonepallet--------------------------------

for i = 1 to mdpHeader.objectCount do
(
	fseek f mdpObjectIndexArray[i].bonePalletOffset#seek_set
	bonePal = bonePallet()
	
	bonePal.hashedName = readshort f
	bonePal.boneCount = readshort f
	bonePal.boneId = #()
	
	for j =1 to bonePal.boneCount do (
		id = readbyte f#unsigned + 1
		append bonePal.boneId id
	)
		
	append bonePalletBuffer bonePal
	
)
---------vertexbuffer------------------------------

for i = 1 to mdpHeader.objectCount do
(
	loop = 1
	offset = mdpObjectIndexArray[i].vertexBufferOffset
	size = mdpObjectIndexArray[i].vertexBufferCount
	
	
	if (mdpObjectIndexArray[i].vertexBufferOffset == 0) then (
		loop = mdpObjectIndexArray[i].faceIndexCount
	)
	
	for n =1 to loop do (
	
		if (mdpObjectIndexArray[i].vertexBufferOffset == 0) then (
			offset = mdpFaceIndexArray[i][n].faceBufferOffset	
			size = mdpFaceIndexArray[i][n].faceBufferSize
			if (offset == 0) then (
				MessageBox "vert offset is 0, I don't know how to handle these"
				return 0
			)
		)
		
		fseek f offset #seek_set
		for j = 1 to size do (
			
			vertexDefinition = bit.and (mdpObjectIndexArray[i].flag) 0x0F
				
					
				if (vertexDefinition == 0x01) then (
					
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsignedm / 128.0) as float	
					
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
				
					r = 255
					g = 255
					b = 255
					a = 255
				
					nx = readshort f
					ny = readshort f
					nz = readshort f
				
					vx = readshort f
					vy = readshort f
					vz = readshort f
					append tempWeightBuffer [weight, weight2]
				) else if (vertexDefinition == 0x02) then (
					
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float					
					
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
				
					r = 255
					g = 255
					b = 255
					a = 255
				
					nx = readshort f
					ny = readshort f
					nz = readshort f
				
					vx = readshort f
					vy = readshort f
					vz = readshort f
					append tempWeightBuffer [weight, weight2, weight3, weight4]
				)  else if (vertexDefinition == 0x03) then (
					
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float					
					weight5 =  (readbyte f#unsigned / 128.0) as float
					weight6 =  (readbyte f#unsigned / 128.0) as float
					weight7 =  (readbyte f#unsigned / 128.0) as float
					weight8 =  (readbyte f#unsigned / 128.0) as float		
					
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
				
					r = 255
					g = 255
					b = 255
					a = 255
				
					nx = readshort f
					ny = readshort f
					nz = readshort f
				
					vx = readshort f
					vy = readshort f
					vz = readshort f
					
					temp = #() -- stupid workaround can't do  more than [1,2,3,4]
					append temp weight
					append temp weight2
					append temp weight3
					append temp weight4
					append temp weight5
					append temp weight6
					append temp weight7
					append temp weight8
					append tempWeightBuffer temp
				)  else if (vertexDefinition == 0x04) then (
				
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
				
					r = readbyte f #unsigned
					g = readbyte f #unsigned
					b = readbyte f #unsigned
					a = readbyte f #unsigned
				
					nx = readshort f
					ny = readshort f
					nz = readshort f
				
					vx = readshort f
					vy = readshort f
					vz = readshort f
				) else if (vertexDefinition == 0x0D) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
					r = 255
					g = 255
					b = 255
					a = 255				
					uk = readshort f
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					nw = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f					
					append tempWeightBuffer [weight, weight2, weight3, weight4]					
				) else if (vertexDefinition == 0x09) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 = (readbyte f#unsigned / 128.0) as float
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
					r = 255
					g = 255
					b = 255
					a = 255
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					nw = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f
					append tempWeightBuffer [weight, weight2]
				) else if (vertexDefinition == 0x0C) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					tu = (readshort f*0.000251)
					tv = (readshort f*-0.000251)
					uk = readshort f
					r = 255
					g = 255
					b = 255
					a = 255
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					uk = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f
					append tempWeightBuffer [weight, weight2]				
				)	else if (vertexDefinition == 0x0A) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
					r = 255
					g = 255
					b = 255
					a = 255
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					nw = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f	
					append tempWeightBuffer [weight, weight2, weight3, weight4]						
				)	else if (vertexDefinition == 0x0B) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float
					weight5 =  (readbyte f#unsigned / 128.0) as float
					weight6 =  (readbyte f#unsigned / 128.0) as float
					weight7 =  (readbyte f#unsigned / 128.0) as float
					weight8 =  (readbyte f#unsigned / 128.0) as float
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
					r = 255
					g = 255
					b = 255
					a = 255
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					nw = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f			
					temp = #() -- stupid workaround can't do  more than [1,2,3,4]
					append temp weight
					append temp weight2
					append temp weight3
					append temp weight4
					append temp weight5
					append temp weight6
					append temp weight7
					append temp weight8
					append tempWeightBuffer temp
				)   else if (vertexDefinition == 0x0E) then (
					weight =  (readbyte f#unsigned / 128.0) as float
					weight2 =  (readbyte f#unsigned / 128.0) as float
					weight3 =  (readbyte f#unsigned / 128.0) as float
					weight4 =  (readbyte f#unsigned / 128.0) as float
					weight5 =  (readbyte f#unsigned / 128.0) as float
					weight6 =  (readbyte f#unsigned / 128.0) as float
					weight7 =  (readbyte f#unsigned / 128.0) as float
					weight8 =  (readbyte f#unsigned / 128.0) as float
					tu = readshort f*0.00025
					tv = readshort f*-0.00025
					uk = readshort f
					r = 255
					g = 255
					b = 255
					a = 255
					nx = readbyte f
					ny = readbyte f
					nz = readbyte f
					nw = readbyte f
					vx = readshort f
					vy = readshort f
					vz = readshort f
					temp = #() -- stupid workaround can't do  more than [1,2,3,4]
					append temp weight
					append temp weight2
					append temp weight3
					append temp weight4
					append temp weight5
					append temp weight6
					append temp weight7
					append temp weight8
					append tempWeightBuffer temp
				)  else if (vertexDefinition == 0x08) then (
					print("there are no verticies for this type")
					return 0
				) else (
					print(bit.intAsHex(vertexDefinition))
					print("I need to add that one")
				)
				append tempVertexBuffer[vx,vy,vz]
				append tempUvBuffer[tu,tv,0]
				append tempNormalBuffer[nx,ny,nz]
				append tempColourBuffer[r,g,b,a]
		)
	)	
		
		append vertexBuffer tempVertexBuffer
		append uvBuffer tempUvBuffer
		append normalBuffer tempNormalBuffer
		append colourBuffer tempColourBuffer
		append weightBuffer tempWeightBuffer
		
		tempVertexBuffer = #()
		tempUvBuffer = #()
		tempNormalBuffer = #()
		tempColourBuffer = #()
		tempWeightBuffer = #()
)

-----------------facebuffer-----------------------------


for i = 1 to mdpHeader.objectCount do (
	if (mdpObjectIndexArray[i].flag2 < 0x10) then (
	
	
		for j = 1 to mdpObjectIndexArray[i].faceIndexCount do (
		
			fseek f mdpFaceIndexArray[i][j].faceBufferOffset #seek_set
		
			for s = 1 to mdpFaceIndexArray[i][j].faceBufferSize-0x02 do (
		
				fa = readshort f #unsigned + 1
				fb = readshort f #unsigned + 1
				fc = readshort f #unsigned + 1
			
			append tempFaceBuffer [fa,fb,fc]
			
			fseek f -0x04 #seek_cur
		)
	)
	append faceBuffer tempFaceBuffer
	
	tempFaceBuffer = #()
	) else (
			m= 1
			for j = 1 to mdpObjectIndexArray[i].faceIndexCount do (
				for s = 1 to mdpFaceIndexArray[i][j].faceBufferSize-2 do (
			
					append tempFaceBuffer [m, (m+1), (m+2)]
					m = m+1
				)
				m = m+2
			)
		append faceBuffer tempFaceBuffer	
		tempFaceBuffer = #()	
	)
)
-----------------buildmesh--------------------------------

for i = 1 to mdpHeader.objectCount do (
	msh = mesh vertices:vertexBuffer[i] faces:faceBuffer[i] material: mat
	msh.numTVerts = uvBuffer[i].count
	setNumCPVVerts = colourBuffer[i].count
	defaultVCFaces msh
	colourMesh msh
	buildTVFaces msh
	for j = 1 to uvBuffer[i].count do setTVert msh j uvBuffer[i][j]
	for j = 1 to faceBuffer[i].count do setTVFace msh j faceBuffer[i][j]
	for j = 1 to normalBuffer[i].count do setnormal msh j normalBuffer[i][j]
	for j = 1 to colourBuffer[i].count do setvertColor msh j colourBuffer[i][j]
		
	--msh.rotation = eulertoquat (eulerAngles 270 0 0)
	
	--bounding box
	scaleToBoundingBox msh mdpObjectIndexArray[i]
	-- name mesh
	msh.name = (bit.intAsHex(mdpObjectIndexArray[i].hashedName) as string)
	--position mesh
	msh.position = [mdpObjectIndexArray[i].posX, mdpObjectIndexArray[i].posY, mdpObjectIndexArray[i].posZ]
	
------------------------materialstuff----------------------------------

    g = 1
	for j = 1 to mdpObjectIndexArray[i].faceIndexCount do (
		fseek f mdpFaceIndexArray[i][j].matIndexOffset #seek_set
		matName = readlong f
		matId = getMatIdFromName matName mat
		
		for s = 1 to mdpFaceIndexArray[i][j].faceBufferSize-2 do (	
			setFaceMatID msh g matId			
			g = g + 1
		)
		
	)
	
-------------------------bonestuff---------------------------------------

	if mdpHeader.boneCount !=0 then (
		max modify mode
		skinMod = skin ()
		addModifier msh skinMod
		select msh
		
		for j =1 to bonePalletBuffer[i].boneCount do (
			boneNumber = bonePalletBuffer[i].boneId[j]
			maxBone = getnodeByName (bit.intAsHex(boneBuffer[boneNumber].hashName) as string)
			skinOps.addBone skinMod maxBone 0
		)
		
		boneNames = for i=1 to (skinOps.GetNumberBones skinMod) collect (skinOps.GetBoneName skinMod i 0)
		
		modPanel.setCurrentObject skinMod

		for j = 1 to weightBuffer[i].count do (
			for k =1 to bonePalletBuffer[i].boneCount do (
				boneNumber = bonePalletBuffer[i].boneId[k]
				boneName = bit.intAsHex(boneBuffer[boneNumber].hashName) as string
				boneIndex = findItem boneNames boneName
				skinOps.SetVertexWeights skinMod j  boneIndex weightBuffer[i][j][k]
			)
		)
		
	max create mode

	)
	
	update msh

---------------------addtomeshgroup-------------------------------------
	parentLayer = LayerManager.getLayerFromName (bit.intAsHex(mdpObjectIndexArray[i].hashedName) as string)
	parentLayer.addNode msh
	
)
)




---------------------cleanUpAndFinish------------------------------------

gc()
fclose f