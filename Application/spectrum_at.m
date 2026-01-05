function spexel_spectrum = spectrum_at(cube, lambda_axis, x, y)

spexel_spectrum = squeeze(cube(y,x,:));

figure()
plot(lambda_axis, spexel_spectrum)

xlabel("λ [nm]")
ylabel("Intensity [-]")

title(sprintf('Spektrum v [x=%d ; y=%d]', x, y))

end
