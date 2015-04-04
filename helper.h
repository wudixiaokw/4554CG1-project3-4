#ifndef __GWU_HELPER__
#define __GWU_HELPER__

void DrawGrids( void ) {
	float step = 0.1f;

	int n = 20;

	float r = step * n;

	glBegin( GL_LINES );
	
	glColor4f( 0.2f, 0.2f, 0.3f, 1.0f );

	for ( int i = -n; i <= n; i++ ) {
		glVertex3f( i * step, 0, -r );
		glVertex3f( i * step, 0, +r );
	}

	for ( int i = -n; i <= n; i++ ) {
		glVertex3f( -r, 0, i * step );
		glVertex3f( +r, 0, i * step );
	}

	glEnd();
}

#endif // __GWU_HELPER__