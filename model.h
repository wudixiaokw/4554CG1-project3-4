#ifndef __GWU_MODEL__
#define __GWU_MODEL__

//================================
// ModelFace
//================================

class ModelFace {
public :
	int		numSides;
	int *	indices;
    vec3    faceNormals;
public :
	ModelFace() {
		numSides = 0;
		indices = NULL;
	}

	~ModelFace() {
		if ( indices ) {
			delete[] indices;
			indices = NULL;
		}
		numSides = 0;
	}
};



//================================
// Model
//================================
class Model {
public :
    Matrix  matrix;
	int			numVerts;
	vec3 *		verts;
	vec3 *      vertsNormals;
    int			numFaces;
    
	ModelFace *	faces;
public :
	Model() {
		numVerts = 0;
		verts = NULL;
        vertsNormals=NULL;
        
		numFaces = 0;
		faces = NULL;
       
        
        matrix.identity();
	}

	~Model() {
		if ( verts ) {
			delete[] verts;
			verts = NULL;
		}
        if ( vertsNormals ) {
			delete[] vertsNormals;
			vertsNormals = NULL;
		}

		numVerts = 0;

		if ( faces ) {
			delete[] faces;
			faces = NULL;
		}
		numFaces = 0;
	}

    void normalize(float v[3]){
        GLfloat d = sqrt(v[0]*v[0] + v[1]*v[1] + v[2]*v[2]);
        v[0] /= d; v[1] /= d; v[2] /= d;
    }
    
    void normCrossProd(float u[3],float v[3],float output[3]){
        output[0] = u[1]*v[2] - u[2]*v[1];
        output[1] = u[2]*v[0] - u[0]*v[2];
        output[2] = u[0]*v[1] - u[1]*v[0];
        normalize(output);
    }
    
	void DrawEdges( void ) {
		
          for(int i=0;i<numFaces;i++){
            glBegin(GL_POLYGON);
           
              for (int k=0; k<faces[i].numSides; k++) {
                  int index=faces[i].indices[k];
              glNormal3f(vertsNormals[index].x,vertsNormals[index].y,vertsNormals[index].z);
              glVertex3fv(verts[index].ptr());
               }
             
              
              glEnd();
            
          }
           

        }
    
        
	void DrawEdges2D( void ) {
		glBegin( GL_LINES );
		for ( int i = 0; i < numFaces; i++ ) {
			for ( int k = 0; k < faces[ i ].numSides; k++ ) {
				int p0 = faces[ i ].indices[ k ];
				int p1 = faces[ i ].indices[ ( k + 1 ) % faces[ i ].numSides ];
				glVertex2fv( verts[ p0 ].ptr() );
				glVertex2fv( verts[ p1 ].ptr() );
			}
		}
		glEnd();
	}

	// calculate AABB
	bool Bound( vec3 &min, vec3 &max ) {
		if ( numVerts <= 0 ) {
			return false;
		}

		min = verts[ 0 ];
		max = verts[ 0 ];

		for ( int i = 1; i < numVerts; i++ ) {
			vec3 v = verts[ i ];

			if ( v.x < min.x ) {
				min.x = v.x;
			} else if ( v.x > max.x ) {
				max.x = v.x;
			}

			if ( v.y < min.y ) {
				min.y = v.y;
			} else if ( v.y > max.y ) {
				max.y = v.y;
			}

			if ( v.z < min.z ) {
				min.z = v.z;
			} else if ( v.z > max.z ) {
				max.z = v.z;
			}
		}

		return true;
	}

	// scale the model into the range of [ -1, 1 ]
	void ResizeModel( void ) {
		// bound
		vec3 min, max;
		if ( !Bound( min, max ) ) {
			return;
		}

		// center
		vec3 center = ( min + max ) * 0.5f;

		// scale factor
		vec3 size = ( max - min ) * 0.5f;

		float r = size.x;
		if ( size.y > r ) {
			r = size.y;
		}
		if ( size.z > r ) {
			r = size.z;
		}

		if ( r < 1e-6f ) {
			r = 0;
		} else {
			r = 1.0f / r;
		}

		// scale to [ -1, 1 ]
		for ( int i = 0; i < numVerts; i++ ) {
			verts[ i ] -= center;
			verts[ i ] *= r;
		}
	}

	// scale model
	void Scale( vec3 a) {
        Matrix temp;
         temp.identity();
         temp.mat[0]=a.x;
         temp.mat[5]=a.y;
         temp.mat[10]=a.z;
         matrix.multiMatrix(temp);
        /*for ( int i = 0; i < numVerts; i++ ) {
			verts[ i ] *= r;
		}*/

	}
    
    
	void Translate( vec3 a) {
		Matrix temp;
        temp.identity();
        temp.mat[12]=a.x;
        temp.mat[13]=a.y;
        temp.mat[14]=a.z;
        matrix.multiMatrix(temp);
        /*for ( int i = 0; i < numVerts; i++ ) {
			verts[ i ].x += a.x;
			verts[ i ].y += a.y;
            verts[ i ].z += a.z;}*/
        // translate ...
    
	}

    void Rotate( vec3 p1, vec3 p2,GLfloat radianAngle )
    {
        float PI = 3.1415926;
        radianAngle=2.0*PI*radianAngle/360.0;
        // rotate ...
        Matrix matQuaternionRot;
        GLfloat axisVectLength= sqrtf((p2.x-p1.x)*(p2.x-p1.x)+(p2.y-p1.y)*(p2.y-p1.y)+(p2.z-p1.z)*(p2.z-p1.z));
        GLfloat cosA =cos(radianAngle);
        GLfloat oneC =1-cosA;
        GLfloat sinA =sin(radianAngle);
        GLfloat ux = (p2.x-p1.x)*(p2.x-p1.x)/axisVectLength;
        GLfloat uy = (p2.y-p1.y)*(p2.y-p1.y)/axisVectLength;
        GLfloat uz = (p2.z-p1.z)*(p2.z-p1.z)/axisVectLength;
        // set up translation matrix for moving p1 to origin
        Translate(-p1);
        //initialize matQuaternionRot to identity matrix
        
    
        matQuaternionRot.identity();
        
        matQuaternionRot.mat[0] = ux*ux*oneC + cosA;
        matQuaternionRot.mat[4] = ux*uy*oneC -uz*sinA;
        matQuaternionRot.mat[8] = ux*uz*oneC +uy*sinA;
        matQuaternionRot.mat[1] = uy*ux*oneC +uz*sinA;
        matQuaternionRot.mat[5] = uy*uy*oneC +cosA;
        matQuaternionRot.mat[9] = uy*uz*oneC -ux*sinA;
        matQuaternionRot.mat[2] = uz*ux*oneC -uy*sinA;
        matQuaternionRot.mat[6] = uz*uy*oneC +ux*sinA;
        matQuaternionRot.mat[10] = uz*uz*oneC +cosA;
        //conbine matquaternionrot with translation matrix
        matrix.multiMatrix(matQuaternionRot);
        
        //set ip inverse mattranslae and concatenate with product of previous two matrices
        Translate(p1);
        
	}
	
    
    // load model from .d file
	bool LoadModel( const char *path ) {
		if ( !path ) {
			return false;
		}

		// open file
		FILE *fp = fopen( path, "r" );
		if ( !fp ) {
			return false;
		}

		// num of vertices and indices
		fscanf( fp, "data%d%d", &numVerts, &numFaces );

		// alloc vertex and index buffer
		verts = new vec3[ numVerts ];
		faces = new ModelFace[ numFaces ];
        vertsNormals =new vec3[numVerts];
		// read vertices
		for ( int i = 0; i < numVerts; i++ ) {
			fscanf( fp, "%f%f%f", &verts[ i ].x, &verts[ i ].y, &verts[ i ].z );
		}

		// read indices
		for ( int i = 0; i < numFaces; i++ ) {
			ModelFace *face = &faces[ i ];

			fscanf( fp, "%i", &face->numSides );
			faces[ i ].indices = new int[ face->numSides ];

			for ( int k = 0; k < face->numSides; k++ ) {
				fscanf( fp, "%i", &face->indices[ k ] );
			}
		}

		// close file
		fclose( fp );

		ResizeModel();
        for(int m=0;m<numVerts;m++){
            vertsNormals[m].set(0, 0, 0);
        }
        for(int i=0;i<numFaces;i++){
            int p[3];
            
            p[0]=faces[i].indices[0];
            p[1]=faces[i].indices[1];
            p[2]=faces[i].indices[2];
            vec3 a,b,c;
            a.set(verts[p[0]].x, verts[p[0]].y, verts[p[0]].z);
            b.set(verts[p[1]].x, verts[p[1]].y, verts[p[1]].z);
            c.set(verts[p[2]].x, verts[p[2]].y, verts[p[2]].z);
            vec3 u,v,nomal;
            u.set(b.x-a.x, b.y-a.y, b.z-a.z);
            v.set(c.x-b.x, c.y-b.y, c.z-b.z);
            float nx,ny,nz,nr;
            nx=u.y*v.z-v.y*u.z;
            ny=u.z*v.x-v.z*u.x;
            nz=u.x*v.y-u.y*v.x;
            nr=sqrtf(nx*nx+ny*ny+nz*nz);
            faces[i].faceNormals.set(nx/nr, ny/nr, nz/nr);
 
            for (int k=0; k<faces[i].numSides; k++) {
                
                int index=faces[i].indices[k];

                vertsNormals[index]+=faces[i].faceNormals;
                
            }
        }
        for(int m=0;m<numVerts;m++){
            vertsNormals[m].normalize();
        }

		return true;
	}
};

#endif // __GWU_MODEL__