#include "gvdb.h"
#include <stdio.h>
#include <iostream>
#include <GL/glew.h>
#include <GL/freeglut.h>

using namespace nvdb;


int main(){
    
    // dummy arguments
    char *myargv [1];
    int myargc=1;
    myargv [0] = strdup("GLEW Test");

    glutInit(&myargc, myargv);
    
    glutCreateWindow("GLEW Test");
    GLenum err = glewInit();
    if (GLEW_OK != err)
    {
        /* Problem: glewInit failed */
        fprintf(stderr, "Error: %s\n", glewGetErrorString(err));
    }
    fprintf(stdout, "Status: Using GLEW %s\n", glewGetString(GLEW_VERSION));

    VolumeGVDB gvdb;

    gvdb.SetDebug ( false );
    gvdb.SetVerbose ( true );
    gvdb.SetProfile ( false, true );
    gvdb.SetCudaDevice ( GVDB_DEV_FIRST );
    
    gvdb.Initialize ();
    gvdb.AddPath ( "/home/gvdb" );

    // gvdb.LoadVBX ( "data.vbx" );

    gvdb.Configure ( 3, 3, 3, 3, 5);
    gvdb.AddChannel ( 0, T_FLOAT, 1 );

    // SetVoxelSize has been removed
    // gvdb.SetVoxelSize ( 0.4, 0.4, 0.4 );
    
    // Topology rebuilding

    // error: class "nvdb::VolumeGVDB" has no member "ClearTopology"
    // gvdb.ClearTopology (); => wrong member function, it should be "Clear"
    gvdb.Clear ();

    int num_pnts = 40;
    Vector3DF pnt[num_pnts];

    // Requesting GVDB to add topology nodes to define the sparse regions 
    // of the spatial domain to be covered
    for (int n=0; n < num_pnts; n++ ) {
        pnt[n].x = n;
        pnt[n].y = n;
        pnt[n].z = n;
        gvdb.ActivateSpace ( pnt[n] );
    }

    gvdb.FinishTopology ();
    // Requesting GVDB to expand or restructure the atlas
    // channels to support the changes in topology

    // Atlas rebuilding

    gvdb.UpdateAtlas ();
    
    //error: class "nvdb::VolumeGVDB" has no member "ClearAtlas"
    // gvdb.ClearAtlas ();

    printf("VDBSize: %d\n", gvdb.getVDBSize());
    
//    Vector3DF bMin = gvdb.getBoundMin();
//    Vector3DF bMax = gvdb.getBoundMax();
    Vector3DF bMin = gvdb.getWorldMin();
    Vector3DF bMax = gvdb.getWorldMax();

    printf("BoundMin: (%f, %f, %f)\n", bMin.x, bMin.y, bMin.z);
    printf("BoundMax: (%f, %f, %f)\n", bMax.x, bMax.y, bMax.z);

    float scale = 100.0;
    float tx, ty, tz;
    tx = 0.0;
    ty = 0.0;
    tz = 0.0;


    gvdb.StartRasterGL();

    Scene* scn = gvdb.getScene();
    scn->AddModel ( "lucy.obj", scale, tx, ty, tz );
    gvdb.CommitGeometry ( 0 );

}