######################################################################################################

### Part I: FUNCTIONS THAT ARE USED IN DATA PROCESSING AND MODELING ###

#the following three functions are used to match the names of samples, mirnas and mrnas
#By using these three functions, we can get the matched mrna expression data and mirna expression data
express_pre = function(mirna_base, mrna_base, name_base, cutoff){
  mirna_sample_name = mirna_base[1,-1]
  mrna_sample_name = mrna_base[1,-1]
  x = match(name_base[, "miRNA"], mirna_sample_name)
  y = match(name_base[, "mRNA"], mrna_sample_name)
  mirna_name1 = mirna_base[-1,1]
  mrna_fullname1 = mrna_base[-1,1]
  mirna_use1 = mirna_base[-1,-1]
  mrna_use1 = mrna_base[-1,-1]
  mirna_use1[is.na(mirna_use1)] = 0
  mrna_use1[is.na(mrna_use1)] = 0
  mirna_use1[mirna_use1 < 0] = 0
  mrna_use1[mrna_use1 < 0] = 0
  mirna_use2 = mirna_use1[,x]
  mrna_use2 = mrna_use1[,y]
  mirna_use = matrix(as.numeric(mirna_use2), nrow = nrow(mirna_use2))
  mrna_use = matrix(as.numeric(mrna_use2), nrow = nrow(mrna_use2))
  mirna_sign = c()
  for(i in 1:nrow(mirna_use)){
    if(sum(mirna_use[i,] == 0) > cutoff * ncol(mirna_use)){
      mirna_sign = c(mirna_sign, i)
    }
  }
  mrna_sign = c()
  for(i in 1:nrow(mrna_use)){
    if(sum(mrna_use[i,] == 0) > cutoff * ncol(mrna_use)){
      mrna_sign = c(mrna_sign, i)
    }
  }
  mrna_usee = mrna_use[-mrna_sign,]
  mrna_fullname = mrna_fullname1[-mrna_sign]
  mirna_usee = mirna_use[-mirna_sign,]
  mirna_name = mirna_name1[-mirna_sign]
  for(i in 1:length(mirna_name)){
    mirna_name[i] = strsplit(mirna_name[i], split = "\\|")[[1]][1]
  }
  #mrna_name_sp1 = mrna_name_sp[mrna_sgn,]
  #mrna_fullname1 = mrna_fullname[mrna_sgn]
  rownames(mirna_usee) = mirna_name
  rownames(mrna_usee) = mrna_fullname
  
  mrna_name = rep(0, length(mrna_fullname))
  mrna_name_all = matrix(data = 0, ncol = 2, nrow = nrow(mrna_base), byrow = TRUE)
  for(i in 1 : length(mrna_fullname)){
    mrna_name[i] = unlist(strsplit(mrna_fullname[i], "\\|"))[1]
    mrna_name_all[i, 1] = unlist(strsplit(mrna_fullname[i], "\\|"))[1]
    mrna_name_all[i, 2] = unlist(strsplit(mrna_fullname[i], "\\|"))[2]
  }
  
  return(list(mirna_usee, mrna_usee, mirna_name, mrna_name, mrna_name_all, mrna_fullname))
}
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
#mirna_mrna_data is used for targetscan, which will select the RNAs that are expressed in a certain percentage of samples
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
mirna_mrna_data = function(mirna_use, mrna_use, mirna_name, mrna_name, mrna_name_sp, mrna_fullname, cutoff){
  mirna_use[is.na(mirna_use)] = 0
  mrna_use[is.na(mrna_use)] = 0
  mirna_use[mirna_use < 0] = 0
  mrna_use[mrna_use < 0] = 0
  mirna_sgn = seq(1, nrow(mirna_use), 1)
  mrna_sgn = seq(1, nrow(mrna_use), 1)
  for (i in 1:nrow(mirna_use)){
    if(sum(mirna_use[i,] == 0) > ncol(mirna_use) * cutoff){
      mirna_sgn[i] = 0
    }
  }
  for (i in 1:nrow(mrna_use)){
    if(sum(mrna_use[i,] == 0) > ncol(mrna_use) * cutoff){
      mrna_sgn[i] = 0
    }
  }  
  mirna_use1 = mirna_use[mirna_sgn,]
  mrna_use1 = mrna_use[mrna_sgn,]
  mirna_name1 = mirna_name[mirna_sgn]
  mrna_name1 = mrna_name[mrna_sgn]
  mrna_name_sp1 = mrna_name_sp[mrna_sgn,]
  mrna_fullname1 = mrna_fullname[mrna_sgn]
  rownames(mirna_use1) = mirna_name1
  rownames(mrna_use1) = mrna_fullname1
  return(list(mirna_use1, mrna_use1, mirna_name1, mrna_name1, mrna_name_sp1, mrna_fullname1))
}
#MMI_location is used to match the validation set with the expression to get the location
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

####the following codes are used to calculate the rank result of different methods
#mirtigo_pop is used to get the position of population-level result of mirtigo algorithm
mirtigo_medfc = function(mirna_use1, mrna_use1, mrna_name, wMRE, sumup, mirna_name, vset, num){
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  pro_matrix_temp = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  pro_matrix_agg = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  for(m in 1:ncol(mirna_use)){
    pro_matrix_temp = (mirna_use[, m] %*% t(mrna_use[, m])) * wMRE / sumup[m]
    pro_matrix_agg = pro_matrix_agg + pro_matrix_temp
  }
  #thres_num = ceiling(length(which(pro_matrix_agg != 0))/100)
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = pro_matrix_agg[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  colnames(sel_mrna_name) = mirna_name[mirna_pos]
  colnames(sel_mrna_score) = mirna_name[mirna_pos]
  return(list(sel_mrna_name, sel_mrna_score, tar_num, pro_matrix_agg))
}
#promise_pop is used to get the position of population-level result of promise algorithm
promise_medfc = function(mirna_use1, mrna_use1, mrna_name, wMRE, mirna_name, vset, num){
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  pro_matrix_mrna = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  pro_matrix_full = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  wMRE_new = t(wMRE)
  for(m in 1:ncol(mirna_use)){
    x = matrix(mrna_use[, m])
    rownames(x) = rownames(wMRE_new)
    z = matrix(mirna_use[, m])
    rownames(z) = colnames(wMRE_new)
    rs = roleswitch(x, z, wMRE_new)
    pro_matrix_temp1 = t(rs$p.x)
    pro_matrix_temp2 = t(rs$p.xz)
    pro_matrix_mrna = pro_matrix_mrna + pro_matrix_temp1
    pro_matrix_full = pro_matrix_full + pro_matrix_temp2
  }
  #thres_num1 = ceiling(length(which(pro_matrix_mrna != 0))/100)
  #thres_num2 = ceiling(length(which(pro_matrix_full != 0))/100)
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  sel_matrix_mrna = pro_matrix_mrna[mirna_pos, ]
  sel_matrix_full = pro_matrix_full[mirna_pos, ]
  sel_name_mrna = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_score_mrna = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_name_full = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_score_full = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num_mrna = rep(0, length(mirna_pos))
  tar_num_full = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_score_mrna[,i] = sort(sel_matrix_mrna[i,], decreasing = TRUE)[1:num]
    temp1 = order(sel_matrix_mrna[i,], decreasing = TRUE)[1:num]
    sel_name_mrna[,i] = as.numeric(mrna_name[temp1,2])
    tar_num_mrna[i] = length(which(sel_matrix_mrna[i,] != 0))
    sel_score_full[,i] = sort(sel_matrix_full[i,], decreasing = TRUE)[1:num]
    temp2 = order(sel_matrix_full[i,], decreasing = TRUE)[1:num]
    sel_name_full[,i] = as.numeric(mrna_name[temp2,2])
    tar_num_full[i] = length(which(sel_matrix_full[i,] != 0))
  }
  return(list(sel_name_mrna, sel_score_mrna, sel_name_full, sel_score_full, tar_num_mrna, tar_num_full))
}
#pearson_cal is used to get the result of pearson correlation
pearson_medfc = function(mirna_use1, mrna_use1, mrna_name, mirna_name, vset, num){
  mirna_use = matrix(as.numeric(mirna_use1),nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1),nrow = nrow(mrna_use1))
  corMat = cor(t(mirna_use), t(mrna_use))
  
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = corMat[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  return(list(sel_mrna_name, sel_mrna_score, tar_num))
}
#LASSO_cal is used to get the result of LASSO
LASSO_medfc = function(mirna_use1, mrna_use1, mrna_name, mirna_name, vset, num){
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  mirna_use = t(scale(t(mirna_use)))
  mrna_use = t(scale(t(mrna_use)))
  
  res = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  for(i in 1:nrow(mrna_use)) {
    aGene = glmnet(t(mirna_use), t(mrna_use)[,i], alpha = 1)$beta
    aGene = rowMeans(as.matrix(aGene))    
    res[,i] = aGene 
  }
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = res[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  return(list(sel_mrna_name, sel_mrna_score, tar_num))
}
#ELASTIC_cal is used to get the result of elastic_net
ELASTIC_medfc = function(mirna_use1, mrna_use1, mrna_name, mirna_name, vset, num){ 
  mirna_use = matrix(as.numeric(mirna_use1), nrow = nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1), nrow = nrow(mrna_use1))
  mirna_use = t(scale(t(mirna_use)))
  mrna_use = t(scale(t(mrna_use)))
  
  res = matrix(data = 0, ncol = nrow(mrna_use), nrow = nrow(mirna_use), byrow = TRUE)
  for(i in 1:nrow(mrna_use)) {
    aGene = glmnet(t(mirna_use), t(mrna_use)[,i], alpha = 0.5)$beta
    aGene = rowMeans(as.matrix(aGene))     
    res[,i] = aGene 
  }
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = res[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  return(list(sel_mrna_name, sel_mrna_score, tar_num))
}
#zscore_cal is use to get the result of zscore
Zscore_medfc = function(mirna_use1, mrna_use1, mrna_name, mirna_name, vset, num){
  mirna_use = matrix(as.numeric(mirna_use1),nrow=nrow(mirna_use1))
  mrna_use = matrix(as.numeric(mrna_use1),nrow=nrow(mrna_use1))
  mirna_use = t(scale(t(mirna_use)))
  mrna_use = t(scale(t(mrna_use)))
  
  res = matrix(data=0,ncol=nrow(mrna_use),nrow=nrow(mirna_use),byrow=TRUE)
  #zAB=(xBminA-meanB)/sdB
  for(i in 1:nrow(mirna_use)){
    for(j in 1:nrow(mrna_use)){
      indexminA = which(mirna_use[i, ] == min(mirna_use[i, ]))
      xBminA = mrna_use[j, indexminA]
      res[i,j] = abs(median(xBminA))
    }
  }
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = res[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  return(list(sel_mrna_name, sel_mrna_score, tar_num))
}
#targetscan_rank is used to get the result of targetscan
targetscan_medfc = function(CWCS, mrna_name, mirna_name, vset, num){
  vset_name = as.vector(vset[1,-1])
  temp = match(vset_name, mirna_name)
  mirna_pos = temp[which(is.na(temp) != TRUE)]
  pro_matrix_sel = CWCS[mirna_pos, ]
  sel_mrna_name = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  sel_mrna_score = matrix(data = 0, ncol = length(mirna_pos), nrow = num, byrow = TRUE)
  tar_num = rep(0, length(mirna_pos))
  for(i in 1: length(mirna_pos)){
    sel_mrna_score[,i] = sort(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    temp = order(pro_matrix_sel[i,], decreasing = TRUE)[1:num]
    sel_mrna_name[,i] = as.numeric(mrna_name[temp,2])
    tar_num[i] = length(which(pro_matrix_sel[i,] != 0))
  }
  return(list(sel_mrna_name, sel_mrna_score, tar_num))
}
#medfc_test is used to get the top mrna matrix of the targeted mirnas
medfc_test = function(vset, mirna_name, sel_mrna_name1, tar_num, num){
  tar_num1 = tar_num[which(tar_num != 0)]
  thres = pmin(tar_num1, num)
  mirna_vali = as.vector(vset[1,-1])
  vset_name = as.vector(vset[-1,1])
  vset_score = vset[-1,-1]
  mirna_pos = match(mirna_vali, mirna_name)
  mirna_pos_use = mirna_pos[which(is.na(mirna_pos) != TRUE)]
  vset_score_use2 = vset_score[,which(is.na(mirna_pos) != TRUE)]
  vset_score_use = vset_score_use2[,which(tar_num != 0)]
  sel_mrna_name = sel_mrna_name1[,which(tar_num != 0)]

  mrna_count = rep(0, ncol(vset_score_use))
  mrnafc_matrix = matrix(data = 0, ncol = ncol(vset_score_use), nrow = nrow(sel_mrna_name), byrow = TRUE)
  for(i in 1:ncol(vset_score_use)){
    temp = match(as.numeric(sel_mrna_name[1:thres[i],i]), as.numeric(vset_name))
    #mrna_count[i] = length(which(is.na(temp) != TRUE))
    temp2 = vset_score_use[temp[which(is.na(temp) != TRUE)], i]
    mrna_count[i] = length(which(is.na(temp2) != TRUE))
    mrnafc_matrix[1:mrna_count[i], i] = temp2[which(is.na(temp2) != TRUE)]
  }
  return(list(mrna_count, mrnafc_matrix))
}
#medfc_vector is used to get the median vector of each mirna 
medfc_vector = function(mrna_count, mrnafc_matrix){
  median_mat = matrix(data = 0, ncol = ncol(mrnafc_matrix), nrow = nrow(mrnafc_matrix), byrow = TRUE)
  for(i in 1:ncol(mrnafc_matrix)){
    for(j in 1:nrow(mrnafc_matrix)){
      median_mat[j,i] = median(as.numeric(mrnafc_matrix[1:j,i]))
    }
  }
  fc_vector = rep(0, max(mrna_count))
  for(i in 1:length(fc_vector)){
    temp1 = which(mrna_count >= i)
    fc_vector[i] = mean(as.numeric(median_mat[i,temp1]))
  }
  return(fc_vector)
}

