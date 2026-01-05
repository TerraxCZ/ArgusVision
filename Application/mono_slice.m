function img = mono_slice(cube, lambda_axis, target_lambda)

[~, li] = min(abs(lambda_axis - target_lambda)); %Najde index nejbližší λ k zadané target_lambda
img = cube(:, :, li);
figure; 
%imagesc(img); colormap gray; colorbar;
imshow(img)
title(sprintf('Řez v \\lambda=%.2f nm (sloupec %d)', lambda_axis(li), li));

end