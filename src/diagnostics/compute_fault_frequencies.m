function freqs = compute_fault_frequencies(rpm)
    shaftFreq = rpm / 60;
    n = 9;
    Bd = 7.94e-3;
    Pd = 39e-3;
    theta = 0;

    freqs = struct();
    freqs.shaft = shaftFreq;
    freqs.FTF  = 0.5 * shaftFreq * (1 - (Bd/Pd) * cos(theta));
    freqs.BPFO = (n / 2) * shaftFreq * (1 - (Bd/Pd) * cos(theta));
    freqs.BPFI = (n / 2) * shaftFreq * (1 + (Bd/Pd) * cos(theta));
    freqs.BSF  = (Pd / Bd) * shaftFreq * (1 - ((Bd/Pd) * cos(theta))^2);
end
