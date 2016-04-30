#include <iostream>
#include <map>
#include <stdio.h>
#include <string>
#include <fstream>
using namespace std;
File *B, *A;
int n, m;
unordered_map<string, int> stuMap;
int score[4][3] = ...;
int main()
{
    fscanf(B,"%d",m);
    string name;
    int id, cl;
    char a[101],b[101];
    for(int i = 0; i < m; i++){
        scanf("%d%s%d", &id, a, &cl);
        name = a;//有一个char*转str的函数
        stuMap[name] = 0;
    }
    fscanf(A,"%d",n);
    for(int i = 0; i < n; i++){
        scanf("%s%s%d", a, b, &cl);
        name = a;
        if(stuMap.find(name) != stuMap.end()){
            int competition;
            switch(b[0]){
                case '华':
                    competition = 0;
                    break;
                case '走':
                    competition = 1;
                    break;
                case '希':
                    competition = 2;
                    break;
                case '美':
                    competition = 3;
                    break;
                default:
                    break;
            }
            int sc = score[competition][cl];
            stuMap[name] += sc;
        }
    }
    //对map按value排序
    return 0;
}

