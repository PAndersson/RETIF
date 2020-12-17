function out = RT_normalize_UVZM(D, nr)

    out = D.data(:,nr);
    out = (out-D.mean)./D.std;

end