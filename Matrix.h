//
//  Matrix.h
//  4554project 2
//
//  Created by rong zhou on 10/30/13.
//  Copyright (c) 2013 rong zhou. All rights reserved.
//

#ifndef _554project_2_Matrix_h
#define _554project_2_Matrix_h

class Matrix {
public:
    float mat[16];

public:
    void multiMatrix(Matrix a) {
        float temp[16];
        
        for(int i=0;i<4;i++){
            for(int j=0;j<4;j++){
                int temp_index = i*4+j;
                int a_index =i*4+0;
                int b_index =0*4+j;
                temp[temp_index] = 0;
                 for(int k=0;k<4;k++){
                   temp[temp_index]+= a.mat[a_index] * mat[b_index];
                   a_index +=1;
                   b_index +=4;
            
             }
            }
        }
        for(int i=0;i<16;i++)
        {
            mat[i]=temp[i];
        }
    }
    void identity() {
        for(int i=0;i<4;i++)
        {
            for(int j=0;j<4;j++)
            {
                if(i==j)
                    mat[i*4+j]=1;
                else
                  mat[i*4+j]=0;
            }
        }
        
        };

    

    
};

#endif
