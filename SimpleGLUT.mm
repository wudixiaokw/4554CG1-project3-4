#include "stdafx.h"

// standard
#include <assert.h>
#include <math.h>
#include <stdio.h>
#include <cstdlib>
#include <ctime>


// glut
#include <GLUT/glut.h>
#include <OpenGL/OpenGL.h>
#import <Foundation/Foundation.h>
#import <AppKit/NSImage.h>

// source
#include "vec3.h"
#include "Matrix.h"
#include "model.h"
#include "helper.h"


//================================
// global variables
//================================
// screen size
int g_screenWidth  = 0;
int g_screenHeight = 0;

// frame index
int g_frameIndex = 0;


GLuint m_wall_texture_id;


// model
Model g_model1;
Model g_model2;
Model g_model3;

vec3 p1(0,0,0), p2(1,0,0),p3(0,1,0);

//================================
// init
//================================
void init( void ) {
	// init something before main loop...
    
	// load model
	g_model1.LoadModel( "duck.d2" );
    g_model1.Scale(vec3(0.5,0.5,0.5));
    g_model1.Translate(vec3(0, 1, 0));
    
    g_model2.LoadModel("cow.d2");
    g_model2.Scale(vec3(0.5,0.5,0.5));
    g_model2.Translate(vec3(0, 1, 0));
    g_model2.Translate(vec3(0, 0, 2));
    
    g_model3.LoadModel("cow.d2");
    g_model3.Scale(vec3(0.5,0.5,0.5));
    g_model3.Translate(vec3(0, 0, -2));
    g_model3.Translate(vec3(0, 1, 0));


 
}


//================================
// update
//================================
void update( void ) {
	// do something before rendering...
}

//================================
// render
//================================

const GLfloat PI = 3.14;

/// record the state of mouse
GLboolean mouserdown = GL_FALSE;
GLboolean mouseldown = GL_FALSE;
GLboolean mousemdown = GL_FALSE;
static GLint mousex = 0, mousey = 0;

static GLfloat center[3]={0.0f,0.0f,0.0f}; /// center position
static GLfloat eye[3]={0.0f,0.1f,0.1f}; /// eye's position

static GLfloat yrotate = PI/4; /// angle between y-axis and look direction
static GLfloat xrotate = PI/4; /// angle between x-axis and look direction
static GLfloat celength = 20.0f;/// lenght between center and eye

static GLfloat mSpeed = 0.4f; /// center move speed
static GLfloat rSpeed = 0.02f; /// rotate speed
static GLfloat lSpeed = 0.4f; /// reserved
/// calculate the eye position according to center position and angle,length
void CalCenterPostion()
{
    if(yrotate > PI) yrotate = PI;   /// 限制看得方向
    if(yrotate < 0.01)  yrotate = 0.01;
    if(xrotate > 2*PI)   xrotate = 0.01;
    if(xrotate < 0)   xrotate = 2 * PI;
    if(celength > 100)  celength = 100;     ///  缩放距离限制
    if(celength < 5)   celength = 5;
    
    /// 下面利用球坐标系计算center的位置，
    eye[0] = center[0] + celength * sin(yrotate) * cos(xrotate);
    eye[1] = center[1] + celength * cos(yrotate);
    eye[2] = center[2] + celength * sin(yrotate) * sin(xrotate);
   
}

/// center moves
void MoveBackward()              /// center 点沿视线方向水平向后移动
{
    center[0] += mSpeed * cos(xrotate);
    center[2] += mSpeed * sin(xrotate);
    CalCenterPostion();
}

void MoveForward()
{
    center[0] -= mSpeed * cos(xrotate);
    center[2] -= mSpeed * sin(xrotate);
    CalCenterPostion();
}

/// visual angle rotates
void RotateLeft()
{
    xrotate -= rSpeed;
     CalCenterPostion();
}

void RotateRight()
{
    xrotate += rSpeed;
     CalCenterPostion();
}

void RotateUp()
{
    yrotate += rSpeed;
     CalCenterPostion();
}

void RotateDown()
{
    yrotate -= rSpeed;
    CalCenterPostion();
}
void MouseFunc(int button, int state, int x, int y)
{
    if(state == GLUT_DOWN)
    {
        if(button == GLUT_RIGHT_BUTTON) mouserdown = GL_TRUE;
        if(button == GLUT_LEFT_BUTTON) mouseldown = GL_TRUE;
        if(button == GLUT_MIDDLE_BUTTON)mousemdown = GL_TRUE;
    }
    else
    {
        if(button == GLUT_RIGHT_BUTTON) mouserdown = GL_FALSE;
        if(button == GLUT_LEFT_BUTTON) mouseldown = GL_FALSE;
        if(button == GLUT_MIDDLE_BUTTON)mousemdown = GL_FALSE;
    }
    mousex = x, mousey = y;
}

/// CALLBACK func for mouse motions
void MouseMotion(int x, int y)
{
    if(mouserdown == GL_TRUE)
    {       /// 所除以的数字是调整旋转速度的，随便设置，达到自己想要速度即可
        xrotate += (x - mousex) / 200.0f;
        yrotate -= (y - mousey) / 200.0f;
    }
    
    if(mouseldown == GL_TRUE)
    {
        celength += (y - mousey) / 25.0f;
    }
    mousex = x, mousey = y;
     CalCenterPostion();
    glutPostRedisplay();
}

void LookAt()            /// 调用 gluLookAt(), 主要嫌直接调用要每次都写好几个参数。。
{
     CalCenterPostion();
    gluLookAt(eye[0], eye[1], eye[2],
              center[0], center[1], center[2],
              0, 1, 0);
}


GLuint getTextureFromFile(const char *fname)
{
    NSString *str = [[NSString alloc] initWithCString:fname];
    NSImage *image = [[NSImage alloc] initWithContentsOfFile:str];
    
    // error loading image
    if (![image isValid])
        return 0;

    
    int texformat = GL_RGB;
    
    // convert our NSImage to a NSBitmapImageRep
    NSBitmapImageRep * imgBitmap =[ [ NSBitmapImageRep alloc ]initWithData: [ image TIFFRepresentation ] ];
    
    //[ imgBitmap retain ];
    // examine & remap format
    switch( [ imgBitmap samplesPerPixel ] )
    {
        case 4:texformat = GL_RGBA;
            break;
        case 3:texformat = GL_RGB;
            break;
        case 2:texformat = GL_LUMINANCE_ALPHA;
            break;
        case 1:texformat = GL_LUMINANCE;
            break;
        default:
            break;
    }
    
    
    GLuint tex_id;
    
    glGenTextures (1, &tex_id);
    glBindTexture(GL_TEXTURE_2D, tex_id);
    glPixelStorei(GL_UNPACK_ALIGNMENT, 1);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_REPEAT);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_LINEAR);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_LINEAR);
    glTexImage2D(GL_TEXTURE_2D, 0, texformat, [image size].width, [image size].height,
                 0, texformat, GL_UNSIGNED_BYTE, [ imgBitmap bitmapData ]);
    
    
    return tex_id;
}
void DrawHouseWall(void)
{
    
        //polygon1
    glFrontFace(GL_CCW);
   
    m_wall_texture_id = getTextureFromFile("/Users/rongzhou/Desktop/simple GLUT/SimpleGlut practice/brickwall.bmp");
    // enable texture mapping and bind texture
    
    
    // setup texture filter
        glEnable(GL_TEXTURE_2D);
	glBindTexture(GL_TEXTURE_2D, m_wall_texture_id);
    // draw polygon with texture coordinate
    
    // disable texture mapping and unbind texture
    

    glBegin(GL_QUADS);

    
    glTexCoord2f(0.0f, 0.0f);  glVertex3f(-2.0f, 0.0f, -2.0f);
    glTexCoord2f(1.0f, 0.0f); glVertex3f(2.0f, 0.0f, -2.0f);
    glTexCoord2f(1.0f, 1.0f); glVertex3f(2.0f, 3.0f, -2.0f);
    glTexCoord2f(0.0f, 1.0f);  glVertex3f(-2.0f, 3.0f,-2.0f);
    
    glTexCoord2f(0.0f, 0.0f); glVertex3f(2.0f, 0.0f, 2.0f);
    glTexCoord2f(1.0f, 0.0f); glVertex3f(2.0f, 0.0f, -2.0f);
    glTexCoord2f(1.0f, 1.0f);glVertex3f(-2.0f, 0.0f, -2.0f);
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-2.0f, 0.0f,2.0f);
    
    glTexCoord2f(0.0f, 1.0f);  glVertex3f(-2.0f, 0.0f, -2.0f);
    glTexCoord2f(0.0f, 0.0f);glVertex3f(-2.0f, 3.0f, -2.0f);
    glTexCoord2f(1.0f, 0.0f); glVertex3f(-2.0f, 3.0f,2.0f);
    glTexCoord2f(1.0f, 1.0f);  glVertex3f(-2.0f, 0.0f, 2.0f);
    
    glTexCoord2f(0.0f, 1.0f); glVertex3f(-2.0f, 3.0f,2.0f);
    glTexCoord2f(1.0f, 1.0f); glVertex3f(2.0f, 3.0f, 2.0f);
    glTexCoord2f(1.0f, 0.0f); glVertex3f(2.0f, 0.0f, 2.0f);
    glTexCoord2f(0.0f, 0.0f);  glVertex3f(-2.0f, 0.0f, 2.0f);
    

    
    glEnd();
    glBindTexture( GL_TEXTURE_2D, 0 );

     glDisable( GL_TEXTURE_2D );
}


void render( void ) {
	// clear color and depth buffer
	glClearColor (0.0, 0.0, 0.0, 1.0);
	glClearDepth ( 1.0 );
	glClear(GL_COLOR_BUFFER_BIT | GL_DEPTH_BUFFER_BIT);
	
	// enable depth test
	glEnable( GL_DEPTH_TEST );
    	// modelview matrix <------------------------------------------
	glMatrixMode( GL_MODELVIEW );
	glLoadIdentity();
    LookAt();
    
    
    
    DrawHouseWall();
	// draw grids
    glEnable(GL_COLOR_MATERIAL);
    glShadeModel(GL_SMOOTH);
    glPolygonMode(GL_FRONT_AND_BACK, GL_FILL);
    glEnable(GL_CULL_FACE);
    
    glEnable(GL_LIGHTING);
    glEnable(GL_LIGHT0);
  
    
    GLfloat specular[]={0.1f,0.1f,0.1f,0.5f};
    GLfloat position2[]={-0.5f,0.5f,0.5f};
    GLfloat ambient[]={0.3f,0.3f,0.3f,1.0f};
    GLfloat diffuse[]={0.6f,0.6f,0.6f,1.0f};

    
    glLightfv(GL_LIGHT0, GL_SPECULAR, specular);
    glLightfv(GL_LIGHT0, GL_AMBIENT, ambient);
    glLightfv(GL_LIGHT0, GL_DIFFUSE, diffuse);
    glLightfv(GL_LIGHT0, GL_POSITION, position2);

    
    GLfloat material_Ka	[] = { 0.11f, 0.06f, 0.11f, 1.0f };
    GLfloat material_Kd	[] = { 0.43f, 0.47f, 0.54f, 1.0f };
    GLfloat material_Ks	[] = { 0.03f, 0.03f, 0.03f, 0.5f };
    GLfloat material_Ke	[] = { 0.10f, 0.00f, 0.10f, 1.0f };
    GLfloat material_Se	    = 1;
    

    
    glMaterialfv(GL_FRONT_AND_BACK, GL_AMBIENT, material_Ka);
    glMaterialfv(GL_FRONT_AND_BACK, GL_DIFFUSE, material_Kd);
    glMaterialfv(GL_FRONT_AND_BACK, GL_SPECULAR, material_Ks);
    glMaterialfv(GL_FRONT_AND_BACK, GL_EMISSION, material_Ke);
    glMaterialf (GL_FRONT_AND_BACK, GL_SHININESS, material_Se);
    
    DrawHouseWall();

	
    glPushMatrix();
    glFrontFace(GL_CCW);
    glMultMatrixf( g_model1.matrix.mat );
    g_model1.DrawEdges();
    glPopMatrix();
    

    glPushMatrix();
    glFrontFace(GL_CCW);
    glMultMatrixf( g_model2.matrix.mat );
    g_model2.DrawEdges();
    glPopMatrix();
    

    glPushMatrix();
    glFrontFace(GL_CCW);
    glMultMatrixf( g_model3.matrix.mat );
    g_model3.DrawEdges();
    glPopMatrix();
  
	// swap back and front buffers
	glutSwapBuffers();
}

//================================
// keyboard input
//================================
void key_press( unsigned char key, int x, int y ) {
	switch (key) {
        case 'w':
            g_model1.Translate(vec3(0, 0.1, 0));
            
            break;
        case 'a':
            g_model1.Translate(vec3(-0.1, 0, 0));
            break;
        case 's':
            g_model1.Translate(vec3(0, -0.1, 0));
            break;
        case 'd':
            g_model1.Translate(vec3(0.1, 0, 0));
            break;
        case 'q':
            g_model1.Translate(vec3(0, 0, 0.1));
            break;
        case 'e':
            g_model1.Translate(vec3(0, 0, -0.1));
            break;
        case 'x':
           
        default:
            break;
    }
}


void special_key( int key, int x, int y ) {
	switch (key) {
        case GLUT_KEY_RIGHT: g_model1.Rotate(p1, p2, 10);//right arrow
            break;
        case GLUT_KEY_LEFT:g_model1.Rotate(p1, p2, -10); //left arrow
            break;
        case GLUT_KEY_UP:g_model1.Rotate(p1, p3, 10); //left arrow
            break;
        case GLUT_KEY_DOWN:g_model1.Rotate(p1, p3, -10); //left arrow
            break;

        default:
            break;
	}
}

//================================
// reshape : update viewport and projection matrix when the window is resized
//================================
void reshape( int w, int h ) {
	// screen size
	g_screenWidth  = w;
	g_screenHeight = h;
	
	// viewport
	glViewport( 0, 0, (GLsizei)w, (GLsizei)h );
    
	// projection matrix <------------------------------------------
	glMatrixMode( GL_PROJECTION );
	glLoadIdentity();
	gluPerspective( 45.0f, (float)w / (float)h, 0.1f, 100.0f );
}


//================================
// timer : triggered every 16ms ( about 60 frames per second )
//================================
void timer( int value ) {
	// increase frame index
	g_frameIndex++;
    
	update();
	
	// render
	glutPostRedisplay();
    
	// reset timer
	glutTimerFunc( 16, timer, 0 );
}

//================================
// main
//================================
int main( int argc, char** argv ) {
	// create opengL window
	glutInit( &argc, argv );
	glutInitDisplayMode( GLUT_DOUBLE | GLUT_RGB |GLUT_DEPTH );
	glutInitWindowSize( 600, 600 );
	glutInitWindowPosition( 100, 100 );
	glutCreateWindow( argv[0] );
    
	// init
	init();
	
	// set callback functions
	glutDisplayFunc( render );
	glutReshapeFunc( reshape );
    glutMouseFunc(MouseFunc);
    glutMotionFunc(MouseMotion);
	glutKeyboardFunc( key_press ); 
	glutSpecialFunc( special_key );
	glutTimerFunc( 16, timer, 0 );
	
	// main loop
	glutMainLoop();
    
	return 0;
}