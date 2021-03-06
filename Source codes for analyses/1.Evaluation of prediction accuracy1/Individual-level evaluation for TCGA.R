######################################################################################################

   ### Part I. FUNCTIONS: FUNCTIONS THAT ARE USED IN DATA PROCESSING AND MODELING ###

#The following three functions are used to match the names of samples, mirnas and mrnas
#By using these three functions, we can get the matched mrna expression data and mirna expression data
name_func = function(name_base, mirna_base, mrna_base){
  x = match(name_base[, "miRNA"], mirna_base[1, ])
  y = match(name_base[, "mRNA"], mrna_base[1, ])
  return(list(x,y))
}
mirna_matrix = function(name_base, mirna_base, mirna_name, mirna){  
  mirna_name1 = rep(0,nrow(mirna_base))
  for(i in 1:nrow(mirna_base)){
    mirna_name1[i] = unlist(strsplit(mirna_base[i,1],"\\|"))[1]
  }
  mirna_use = mirna_base[mirna_name1%in%mirna, mirna_name]
  mirna_name1 = mirna_name1[mirna_name1%in%mirna]
  return(list(mirna_use, mirna_name1))
}
mrna_matrix = function(name_base, mrna_base, mrna_name, mrna){
  mrna_exist = rep(0,nrow(mrna_base))
  mrna_name_all = matrix(data = 0, ncol = 2, nrow = nrow(mrna_base), byrow = TRUE)
  mrna_name1 = rep(0, nrow(mrna_base))
  for(i in 1 : nrow(mrna_base)){
    mrna_name1[i] = unlist(strsplit(mrna_base[i, 1], "\\|"))[1]
    mrna_name_all[i, 1] = unlist(strsplit(mrna_base[i, 1], "\\|"))[1]
    mrna_name_all[i, 2] = unlist(strsplit(mrna_base[i, 1], "\\|"))[2]
    if(mrna_name1[i] %in% mrna == 1){
      mrna_exist[i] = i
    }
  }
  mrna_use = mrna_base[mrna_exist, mrna_name]
  mrna_name1 = mrna_name1[mrna_exist]
  mrna_name_sp = mrna_name_all[mrna_exist, ]
  mrna_fullname = mrna_base[mrna_exist, 1]
  return(list(mrna_use, mrna_name1, mrna_name_sp, mrna_fullname))
}
#mirna_mrna_data_unselected will select the RNAs that are expressed in at least one sample
mirna_mrna_data_unselected = function(mirna_use, mrna_use, mirna_name, mrna_name, mrna_name_sp, mrna_fullname){
  mirna_use[is.na(mirna_use)] = 0
  mrna_use[is.na(mrna_use)] = 0
  mirna_use[mirna_use < 0] = 0
  mrna_use[mrna_use < 0] = 0
  mirna_sgn = seq(1, nrow(mirna_use), 1)
  mrna_sgn = seq(1, nrow(mrna_use), 1)
  for (i in 1:nrow(mirna_use)){
    if(sum(mirna_use[i,] == 0) == ncol(mirna_use)){
      mirna_sgn[i] = 0
    }
  }
  for (i in 1:nrow(mrna_use)){
    if(sum(mrna_use[i,] == 0) == ncol(mrna_use)){
      mrna_sgn[i] = 0
    }
  }  
  mirna_use1 = mirna_use[mirna_sgn, ]
  mrna_use1 = mrna_use[mrna_sgn, ]
  mirna_name1 = mirna_name[mirna_sgn]
  mrna_name1 = mrna_name[mrna_sgn]
  mrna_name_sp1 = mrna_name_sp[mrna_sgn, ]
  mrna_fullname1 = mrna_fullname[mrna_sgn]
  rownames(mirna_use1) = mirna_name1
  rownames(mrna_use1) = mrna_fullname1
  return(list(mirna_use1, mrna_use1, mirna_name1, mrna_name1, mrna_name_sp1, mrna_fullname1))
}
#MMI_location is used to get the position of the validation set in the predicted matrix
MMI_location = function(Vset, mirna_name, mrna_name){
  Vset_loc = c(0, nrow(Vset))
  temp1 = as.numeric(mrna_name[, 2])
  temp2 = match(Vset[, 1], temp1)
  temp3 = match(Vset[, 2], mirna_name)
  for(i in 1 : nrow(Vset)){
    if(is.na(temp2[i]) == FALSE && is.na(temp3[i]) == FALSE){
      Vset_loc[i] = length(mirna_name) * (temp2[i] - 1) + temp3[i]
    }
  }  
  return(Vset_loc)
}
#mirna_mrna_loc is used to reshape the wMRE (or qMRE) matrix to fit the expression data
mirna_mrna_loc = function(mirna_name, mrna_name, mirna, mrna, wMRE, mrna_fullname){
  mirna_loc = match(mirna_name, mirna)
  mrna_loc = match(mrna_name, mrna)
  wMRE = t(wMRE)
  wMRE_use = wMRE[mirna_loc, mrna_loc]
  rownames(wMRE_use) = mirna_name
  colnames(wMRE_use) = mrna_fullname
  return(list(mirna_loc, mrna_loc, wMRE_use))
}

####the following codes are used to calculate the rank result of different methods
#sum_mirtigo is used to calculate the normalization coefficient of mirtigo algorithm
sum_mirtigo = function(mirna, mrna, wMRE){
  res = rep(0, ncol(mirna))
  for(i in 1:ncol(mirna)){
    mirna_use1 = as.numeric(mirna[, i])
    mrna_use1 = as.numeric(mrna[, i])
    temp = mirna_use1 %*% t(mrna_use1)
    temp2 = wMRE*temp
    res[i] = sum(temp2)
  }
  return(res)
}
#mirtigo_sam is used to get the position of sample-level result of mirtigo algorithm
mirtigo_sam = function(mirna_use1, mrna_use1, wMRE, sumup, thres_num, vset){
  num = thres_num / 100
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  pro_matrix_samp = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  match_matrix_samp = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  match_samp = matrix(data = 0, ncol = ncol(mrna_use), nrow = num, byrow = TRUE)
  
  for(m in 1 : ncol(mirna_use)){
    pro_matrix_temp = (mirna_use[, m] %*% t(mrna_use[, m])) * wMRE/sumup[m]
    pro_matrix_samp[, m] = order(pro_matrix_temp, decreasing = TRUE)[1 : thres_num]
    match_matrix_samp[, m] = pro_matrix_samp[, m] %in% vset
  }
  for(m in 1: ncol(mirna_use)){
    for(k in 1 : num){
      match_samp[k, m] = sum(match_matrix_samp[(1 : (100 * k)), m]) / (100 * k)
    }
  }
  return(match_samp)
}
#promise_sam is used to get the position of sample-level result of promise algorithm
promise_sam = function(mirna_use1, mrna_use1, wMRE, thres_num, vset){
  num = thres_num / 100
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  pro_samp_mrna = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  pro_samp_full = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  match_matrix_samp_mrna = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  match_matrix_samp_full = matrix(data = 0, ncol = ncol(mrna_use), nrow = thres_num, byrow = TRUE)
  match_samp_mrna = matrix(data = 0, ncol = ncol(mrna_use), nrow = num, byrow = TRUE)
  match_samp_full = matrix(data = 0, ncol = ncol(mrna_use), nrow = num, byrow = TRUE)
  wMRE_new = t(wMRE)
  
  for(m in 1:ncol(mirna_use)){
    x = matrix(mrna_use[, m])
    rownames(x) = rownames(wMRE_new)
    z = matrix(mirna_use[, m])
    rownames(z) = colnames(wMRE_new)
    rs = roleswitch(x, z, wMRE_new)
    pro_matrix_mrna = t(rs$p.x)
    pro_matrix_full = t(rs$p.xz)
    pro_samp_mrna[, m] = order(pro_matrix_mrna, decreasing = TRUE)[1 : thres_num]
    pro_samp_full[, m] = order(pro_matrix_full, decreasing = TRUE)[1 : thres_num]
    match_matrix_samp_mrna[, m] = pro_samp_mrna[, m] %in% vset
    match_matrix_samp_full[, m] = pro_samp_full[, m] %in% vset
  }
  for(m in 1: ncol(mirna_use)){
    for(k in 1 : num){
      match_samp_mrna[k, m] = sum(match_matrix_samp_mrna[(1 : (100 * k)), m]) / (100 * k)
      match_samp_full[k, m] = sum(match_matrix_samp_full[(1 : (100 * k)), m]) / (100 * k)
    }
  }
  return(list(match_samp_mrna, match_samp_full))
}

####################################################################################################

   ### Part II. INPUT DATA: INPUT FOR POPULATION-LEVEL EVALUATION ###

#the following package is used for promise method and expression-based methods
library(Roleswitch)
#first read in the files we need to use, which contains:
#input for mirtigo algorithm: mirna expression, mrna expression, CWCS_matrix, mirna list, mrna list
#input for promise algorithm: mirna expression, mrna expression, qMRE_matrix, mirna list, mrna list
#input for validation: Vset
mrna = as.matrix(read.table("mrna_list.txt", head = TRUE, sep = "\t"))
mirna = as.matrix(read.table("mirna_list.txt", head = TRUE, sep = "\t"))
qMRE_matrix = as.matrix(read.table("qMRE_all.txt", head = TRUE, sep = "\t"))
qMRE_conserved_matrix = as.matrix(read.table("conserved_qMRE.txt", head = TRUE, sep = "\t"))
CWCS_matrix1 = as.matrix(read.table("wMRE_all.txt", head=TRUE, sep = "\t"))
CWCS_matrix = abs(CWCS_matrix1)
Vset = read.table("V1.txt", head = TRUE, sep = "\t")
name_cancer = as.matrix(read.table("TCGA_ESCA_1to1.txt", head = TRUE, sep = "\t"))
mirna_cancer = as.matrix(read.table("ESCA.miRseq_mature_RPM_log2.txt", head = FALSE, sep = "\t"))
mrna_cancer = as.matrix(read.table("ESCA.uncv2.mRNAseq_RSEM_normalized_log2.txt",head = FALSE, sep = "\t"))
rm(CWCS_matrix1)
gc()

####################################################################################################

   ### Part III. MAIN PROGRAM: MAIN FUNCTIONS ###

#the following code is used to do the preparation.
thres_num = 5000
x = name_func(name_cancer, mirna_cancer, mrna_cancer)
z1 = mirna_matrix(name_cancer, mirna_cancer, x[[1]], mirna)
z2 = mrna_matrix(name_cancer, mrna_cancer, x[[2]], mrna)
z3 = mirna_mrna_data_unselected(z1[[1]], z2[[1]], z1[[2]], z2[[2]], z2[[3]], z2[[4]])
z5 = MMI_location(Vset, z3[[3]], z3[[5]]) #this is used to locate the validation set
z6 = mirna_mrna_loc(z3[[3]], z3[[4]], mirna, mrna, qMRE_matrix, z3[[6]])
z6_con = mirna_mrna_loc(z3[[3]], z3[[4]], mirna, mrna, qMRE_conserved_matrix, z3[[6]])
z7 = mirna_mrna_loc(z3[[3]], z3[[4]], mirna, mrna, CWCS_matrix, z3[[6]])

#the following code is used to calculate the comparison result of five methods (mirtigo + 4 Promise)
z8 = sum_mirtigo(z3[[1]], z3[[2]], z7[[3]]) 
z9 = mirtigo_sam(z3[[1]], z3[[2]], z7[[3]], z8,  thres_num, z5) #get the result of mirtigo
z10 = promise_sam(z3[[1]], z3[[2]], z6[[3]], thres_num, z5) #get the result of promise
z10_con = promise_sam(z3[[1]], z3[[2]], z6_con[[3]], thres_num, z5) #get the result of promise conserved

write.table(z9,file="sample comparison result of mirtigo.txt",quote=FALSE,sep="\t")
write.table(z10[[1]],file="sample comparison result of promise mrna.txt",quote=FALSE,sep="\t")
write.table(z10[[2]],file="sample comparison result of promise full.txt",quote=FALSE,sep="\t")
write.table(z10_con[[1]],file="sample comparison result of promise conserve mrna.txt",quote=FALSE,sep="\t")
write.table(z10_con[[2]],file="sample comparison result of promise conserve full.txt",quote=FALSE,sep="\t")
