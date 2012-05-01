/* 
 * File:   main.c
 * Author: matheus
 *
 * Created on June 23, 2011, 4:04 PM
 */

#include <stdlib.h>
#include <math.h>

#define nulo -1
#define ordena 1
/*
 * 
 */
typedef struct {
    int n;
    int freq;
    double prob;
    double prob_acumulada;
    double desvio_medio;
}numeros_t;

int LerNumeros2(FILE* pfile, int** numeros){
    int tmp;
    int cont=0;
    char linha;
    //linha=(char*)malloc(10000000*sizeof(char));
    //fgets(linha,10000000,pfile);
    
    while(fscanf(pfile,"%d%c",&tmp,&linha)!=EOF){
        cont++;
        *numeros=(int*)realloc((*numeros),cont*sizeof(int));
        (*numeros)[cont-1]=tmp;
        //printf("%d\n",(*numeros)[cont-1]);
    }
    return cont;
}


int LerNumeros(FILE* pfile, int** numeros){
    int tmp;
    int cont=0;
    while(fscanf(pfile,"%d",&tmp)!=EOF){
        cont++;
        (*numeros)=(int*)realloc((*numeros),cont*sizeof(int));
        (*numeros)[cont-1]=tmp;
        //printf("%d\n",(*numeros)[cont-1]);
    }
    return cont;
}

int OlharNumerosDiferentes(int* n,int tam){
    int i=0;
    int k=0;
    int diferentes=0;
    int *cpy;
    cpy=(int*)malloc(tam*sizeof(int));
    for(i=0;i<tam;i++){
        cpy[i]=n[i];
    }
    
    for(i=0;i<tam;i++){
        if(cpy[i]==nulo) continue;
        for(k=i+1;k<tam;k++){
            if(cpy[i]==cpy[k]){
                cpy[k]=nulo;
            }
        }
        cpy[i]=nulo;
        diferentes++;
    }
    printf("Diferentes: %d\n",diferentes);
    return diferentes;
}

int Frequencia(numeros_t* N,int* n, int tam, int diferentes){
    int i=0;
    int k=0;
    int Ncont=0;
    int soma_dist=0;
    //Soma Dist
    for(i=0;i<tam;i++){
        soma_dist+=n[i];
    }
    
    for(i=0;i<tam;i++){
        if(n[i]==nulo)continue;
        
        N[Ncont].n=n[i];
        N[Ncont].freq=1;
        
        for(k=i+1;k<tam;k++){
            if(N[Ncont].n==n[k]){
                N[Ncont].freq++;
                n[k]=nulo;
            }
        }
        Ncont++;        
    }
    
    return soma_dist;
}

void OrdenarN(numeros_t*N,int diferentes){
    int i=0;
    int k=0;
    int j=0;
    int tmp;
    
  
    for(i=0;i<diferentes;i++){
        for(k=i+1;k<diferentes;k++){
            if(N[i].n>N[k].n){
               
                
                tmp=N[i].n;
                N[i].n=N[k].n;
                N[k].n=tmp;
                
                tmp=N[i].freq;
                N[i].freq=N[k].freq;
                N[k].freq=tmp;
                
               
            }
        }   
    }
}

void Imprimir2(numeros_t* N, int diferentes){
    if(ordena){
        printf("Ordenando...\n");
        OrdenarN(N,diferentes);
    }
    printf("Imprimindo...\n");
    FILE* saida;
    saida=fopen("saida_espacial.txt","w");
    int i=0;
    for(i=0;i<diferentes;i++){
        //printf("%d %d %f\n",N[i].n,N[i].freq,N[i].prob);
        fprintf(saida,"%d %d %f %f\n",N[i].n,N[i].freq,N[i].prob,N[i].prob_acumulada);
    }
    fclose(saida);
}

double CalcularDesvio(numeros_t* N,int diferentes,double media){
    int i=0;
    double total=0;
    
    for(i=0;i<diferentes;i++){
        N[i].desvio_medio=(double)N[i].freq-media;
    }
    
    for(i=0;i<diferentes;i++){
        total+=pow(N[i].desvio_medio,2);
    }
    total=total/(double)13;
    total=sqrt(total);
    return total;
}

void Imprimir(numeros_t* N, int diferentes){
    if(ordena){
        printf("Ordenando...\n");
        OrdenarN(N,diferentes);
    }
    printf("Imprimindo...\n");
    FILE* saida;
    saida=fopen("saida_temporal.txt","w");
    int i=0;
    for(i=0;i<diferentes;i++){
        //printf("%d %d %f\n",N[i].n,N[i].freq,N[i].prob);
        fprintf(saida,"%d %d %f %f\n",N[i].n,N[i].freq,N[i].prob,N[i].prob_acumulada);
    }
    fclose(saida);
}

void Probabilidade(numeros_t* N, int diferentes){
    
    //Calcular total de frequencia
    double total=0;
    int i=0;
    double prob_acumulada=0;
    
    for(i=0;i<diferentes;i++){
        total+=N[i].freq;
    }
    //Calcular prob
    for(i=0;i<diferentes;i++){
        N[i].prob=(double)N[i].freq/(double)total;
        prob_acumulada+=N[i].prob;
        N[i].prob_acumulada=prob_acumulada;
    }
    //Conferir prob;
    total=0;
    for(i=0;i<diferentes;i++){
        total+=N[i].prob;
    }
    printf("Se o valor da soma de probabilidade for proximo a 1 o calculo foi correto:\n");
    printf("Soma: %f\n",total);
}



int main(int argc, char** argv) {
    FILE* pfile;
    FILE* psaida;
    
    int* n;
    numeros_t* N;
    int nNumeros=0;
    int i=0;
    int k=0;
    int diferentes=0;
    int f_total=0;
    double media=0.0;
    double desviopadrao=0.0;
    double erro_da_media_95=0.0;
    
    pfile=fopen(argv[1],"r");
    if(pfile==NULL){
        printf("Falha ao ler o arquivo\n");
        return 0;
    }
    
     psaida=fopen("dados_tmp.txt","w");
    if(psaida==NULL){
        printf("Falha ao ler o arquivo\n");
        return 0;
    }
    
    n=(int*)malloc(sizeof(int));
    
    printf("Lendo Localidade Temporal...\n");
    nNumeros=LerNumeros2(pfile,&n); 
    printf("Contando Numeros diferentes Localidade Temporal...\n");
    diferentes=OlharNumerosDiferentes(n,nNumeros);
    
    N=(numeros_t*)malloc(diferentes*sizeof(numeros_t));
    printf("Calculando Frequencia Localidade Temporal...\n");
    f_total=Frequencia(N,n,nNumeros,diferentes);
    printf("Calculando Probabilidade Localidade Temporal...\n");
    Probabilidade(N,diferentes);
    Imprimir(N,diferentes);
    
    //Imprimir dados
    media=(double)f_total/nNumeros;
    
    
    fprintf(psaida,"Dados Localidade Temporal\n");
    fprintf(psaida,"Media: %f\n",media);
    desviopadrao=CalcularDesvio(N,diferentes,media);
    fprintf(psaida,"Desvio Padrao: %f\n",desviopadrao);
    fprintf(psaida,"Coeficiente de Variacao: %f\n",media/desviopadrao);
    fprintf(psaida,"Erro da media(95%% de confianca):+/- %f\n",(1.96*desviopadrao)/sqrt(media));
    
    
    
    
    
    
    fclose(pfile);
    //////////////////////////////////////////////////////////
    //////////////////////////////////////////////////////////
    
    
    pfile=fopen(argv[2],"r");
    if(pfile==NULL){
        printf("Falha ao ler o arquivo\n");
        return 0;
    }
    n=(int*)malloc(sizeof(int));
    printf("Lendo Localidade Espacial ...\n");
    nNumeros=LerNumeros2(pfile,&n);
    printf("Contando Numeros diferentes Localidade Espacial...\n");
    diferentes=OlharNumerosDiferentes(n,nNumeros);
    
    N=(numeros_t*)malloc(diferentes*sizeof(numeros_t));
    printf("Calculando Frequencia Localidade Espacial...\n");
    Frequencia(N,n,nNumeros,diferentes);
    printf("Calculando Probabilidade Localidade Espacial...\n");
    Probabilidade(N,diferentes);
    Imprimir2(N,diferentes);
   
    
    
    return (EXIT_SUCCESS);
}

