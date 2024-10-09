#include("loadSPP.jl")
#include("setSPP.jl")


using JuMP, GLPK



print(pwd())
Coef,Contrainte=loadSPP("../dat/b.dat")

function solve(Coef::Vector{Int64},Contrainte::Matrix{Int64},solverSelected) 
    spp=setSPP(Coef,Contrainte)
    set_optimizer(spp, solverSelected)
    optimize!(spp)
    println("z = ", objective_value(spp))
    print("x = "); println(value.(spp[:x]))
end
function solveDirect(Coef::Vector{Int64},Contrainte::Matrix{Int64}) 

    solve(Coef,Contrainte,GLPK.Optimizer)    
end

function calculerFctObjectif(sol,Coef)
    n=size(Coef,1)
    z=0
    for i in 1:n
        z+=sol[i]*Coef[i]
    end
    return z
end

function afficherMatrice(A) 
    n,m=size(A)
    for i in 1:n 
        for j in 1:m
            print(string(A[i,j]))
            print(" ")
        end
        println("")
    end
end


function construction(Coef::Vector{Int64},Contrainte::Matrix{Int64}) 
    nbContrainte,nbVariable=size(Contrainte)
    
    #tab des sols
    sol=zeros(nbVariable)
    
    #somme des lignes
    tab=sum(Contrainte,dims=1)

    Var=Vector{Int}(undef,0)
    
    traiteV=fill(false,nbVariable)
    traiteC=fill(false,nbContrainte)
    # tableau des numéros de variable
    val=[i for i in 1:nbVariable]
    
    #tableau des u
    u=fill(0.0,nbVariable)

   

    for i in 1:nbVariable
        u[i]=Coef[i]/tab[i]
    end
    oldU=deepcopy(u)
    oldCoef=deepcopy(Coef)
    oldVal=deepcopy(val)
   
    # ----------------
    
    while(!isempty(val))
        s=size(val,1)
        # on recupère l'index du max de u 
        index=argmax(u)
        max=u[index]
      
    
        t=fill(0,nbContrainte)
        
        
        #mise à jour de la sol
        sol[val[index]]=1
        traiteV[val[index]]=true
        # à refaire
        #----------------->
        

        #
       
        nb=1
   
        # A REFAIRE PAS OPTIMISER TROUVER AUTRE FACONS
        for i in 1:nbContrainte
            
            if(Contrainte[i,val[index]]==1)
                
                t[nb]=i
                nb+=1
                traiteC[i]=true
               # println(Contrainte[i,val[index]])
                
            
        
            end
        end 
       
        #afficherMatrice(Contrainte)
        t=t[1:(nb-1)]

        A=Contrainte[t,:]
 
        A=sum(A,dims=1)
    
        Var=Vector{Int}(undef,0)
        
       #O(n^2)

       #On prend les variable qui ont 0 dans les lignes de la variable courante comme c'est <=1 
     

       #afficherMatrice(Contrainte)
      
    
        
        for i in 1:nbVariable
            if(A[i]==0 && traiteV[i]==false) 
                
                push!(Var,i)
            end
        end
        s=size(Var,1)
        fa=true
        A=Vector{Int64}(undef,0)
        for i in 1:s
           fa=true
            for j in 1:nbContrainte
              
                if(Contrainte[j,Var[i]]==1 && traiteC[j]==true)
                    
                   fa=false
              
                end
                
                
            end
            if(fa==true)
                push!(A,Var[i])
            end

        end
        Var=deepcopy(A)
        #println(A)
        #println(Var)
        #ceux qui sont disponible=ceux où A[i]=0 donc dans l'exemple la v.a 4 et 7 sont dispo 
       
        Coef=oldCoef[Var] #O(n)
        
        u=oldU[Var]
 
        val=oldVal[Var]
       

    
    end
  
 
  
    println(calculerFctObjectif(sol,oldCoef))
    println( sol )
    #return sol
end











construction(Coef,Contrainte)

#@show Coef
#@show Contrainte
#solveDirect(Coef,Contrainte);