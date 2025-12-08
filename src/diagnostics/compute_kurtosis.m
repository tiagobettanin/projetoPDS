function k = compute_kurtosis(x)
    x = x(:);
    mu = mean(x);
    sigma = std(x);
    if sigma == 0
        k = NaN;
        return;
    end
    k = mean(((x - mu) / sigma).^4);
end
