function energy = compute_envelope_band_energy(f, spectrum, centerFreq, halfWidth)
    if centerFreq <= 10
        energy = 0;
        return;
    end
    lowBound = max(10, centerFreq - halfWidth);
    highBound = centerFreq + halfWidth;
    mask = (f >= lowBound) & (f <= highBound);
    if ~any(mask)
        energy = 0;
        return;
    end
    energy = trapz(f(mask), spectrum(mask));
end
