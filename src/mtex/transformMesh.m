function ebsdMesh = transformMesh(ebsdData, dx_suggested)
  % transformMesh Refine the mesh grid of an EBSD dataset.
  % This function refines the mesh based on a suggested grid spacing (dx).
  % It computes the number of grid points in X and Y directions, and rounds
  % each up to the next power of two for compatibility and efficiency.
  %
  % Inputs:
  %   ebsdData - EBSD dataset to be interpolated.
  %   dx_suggested - Suggested mesh size (spacing between grid points).
  %
  % Output:
  %   ebsdMesh - Interpolated EBSD dataset with a refined 2^n x 2^n grid.
  
    % Extract boundary coordinates
    [xmin, xmax, ymin, ymax] = ebsdData.extend;
    Lx = xmax - xmin;
    Ly = ymax - ymin;
  
    % Compute initial number of grid points
    nx = ceil(Lx / dx_suggested) + 1; % +1 to include both ends
    ny = ceil(Ly / dx_suggested) + 1;
  
    % Find the next power of 2 that is >= nx and ny
    nx_pow2 = 2^nextpow2(nx);
    ny_pow2 = 2^nextpow2(ny);
  
    % Recompute actual grid spacing to fit the domain
    dx_actual = Lx / (nx_pow2 - 1);
    dy_actual = Ly / (ny_pow2 - 1);
  
    % Create the new grid
    xNew = linspace(xmin, xmax, nx_pow2);
    yNew = linspace(ymin, ymax, ny_pow2);
    [X, Y] = meshgrid(xNew, yNew);
  
    % Interpolate EBSD data
    ebsdMesh = interp(ebsdData, X(:), Y(:));
  
    % (Optional) Print info
    fprintf('Requested dx: %.4f µm\n', dx_suggested);
    fprintf('Actual dx: %.4f µm, dy: %.4f µm\n', dx_actual, dy_actual);
    fprintf('Grid size: %d x %d (both are 2^n)\n', nx_pow2, ny_pow2);
  end
  