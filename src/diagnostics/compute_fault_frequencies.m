function freqs = compute_fault_frequencies(rpm)
    shaftFreq = rpm / 60;

    freqs = struct();

    freqs.shaft = shaftFreq;
    freqs.FTF  = 11.92;
    freqs.BPFO = 107.305;
    freqs.BPFI = 162.095;
    freqs.BSF  = 141.09;
end
