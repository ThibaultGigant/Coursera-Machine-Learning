function [J grad] = nnCostFunction(nn_params, ...
                                   input_layer_size, ...
                                   hidden_layer_size, ...
                                   num_labels, ...
                                   X, y, lambda)
%NNCOSTFUNCTION Implements the neural network cost function for a two layer
%neural network which performs classification
%   [J grad] = NNCOSTFUNCTON(nn_params, hidden_layer_size, num_labels, ...
%   X, y, lambda) computes the cost and gradient of the neural network. The
%   parameters for the neural network are "unrolled" into the vector
%   nn_params and need to be converted back into the weight matrices. 
% 
%   The returned parameter grad should be a "unrolled" vector of the
%   partial derivatives of the neural network.
%

% Reshape nn_params back into the parameters Theta1 and Theta2, the weight matrices
% for our 2 layer neural network
Theta1 = reshape(nn_params(1:hidden_layer_size * (input_layer_size + 1)), ...
                 hidden_layer_size, (input_layer_size + 1));

Theta2 = reshape(nn_params((1 + (hidden_layer_size * (input_layer_size + 1))):end), ...
                 num_labels, (hidden_layer_size + 1));

% Setup some useful variables
m = size(X, 1);
         
% You need to return the following variables correctly 
J = 0;
Theta1_grad = zeros(size(Theta1));
Theta2_grad = zeros(size(Theta2));

% ====================== YOUR CODE HERE ======================
% Instructions: You should complete the code by working through the
%               following parts.
%
% Part 1: Feedforward the neural network and return the cost in the
%         variable J. After implementing Part 1, you can verify that your
%         cost function computation is correct by verifying the cost
%         computed in ex4.m
%
% Part 2: Implement the backpropagation algorithm to compute the gradients
%         Theta1_grad and Theta2_grad. You should return the partial derivatives of
%         the cost function with respect to Theta1 and Theta2 in Theta1_grad and
%         Theta2_grad, respectively. After implementing Part 2, you can check
%         that your implementation is correct by running checkNNGradients
%
%         Note: The vector y passed into the function is a vector of labels
%               containing values from 1..K. You need to map this vector into a 
%               binary vector of 1's and 0's to be used with the neural network
%               cost function.
%
%         Hint: We recommend implementing backpropagation using a for-loop
%               over the training examples if you are implementing it for the 
%               first time.
%
% Part 3: Implement regularization with the cost function and gradients.
%
%         Hint: You can implement this around the code for
%               backpropagation. That is, you can compute the gradients for
%               the regularization separately and then add them to Theta1_grad
%               and Theta2_grad from Part 2.
%

X = [ ones(m, 1) X ];

% Create a Y matrix representing in lines how y should be for every training example
Y = (y == 1);
for i=2:num_labels
  Y = [Y (y == i)];
endfor

% Compute first and second layers
H_1 = [ ones(m, 1) sigmoid(X * Theta1')];
H = sigmoid(H_1 * Theta2');

% Compute log and 1 - log for each value
logH = log(H);
logUnMoinsH = log(1 - H );

% Compute cost by iterating on the classes, not on test values, to save time
J = 0;
for k=1:num_labels
  J += sum(-logH(:,k).*(y == k) - logUnMoinsH(:,k) .* (1 - (y == k)));
endfor
J /= m;

% Add cost regularization
J += lambda / (2*m) * (sum(sum(Theta1(:, 2:end).^2)) + sum(sum(Theta2(:, 2:end).^2)));


% Backpropagation algorithm
Delta1 = zeros(hidden_layer_size, (input_layer_size + 1));
Delta2 = zeros(num_labels, (hidden_layer_size + 1));
for i=1:m
  % step 1
  a1 = X(i,:)';           % (input_layer_size+1, 1) %%%% le 1 au d�but du X a d�j� �t� rajout�
  z2 = Theta1 * a1;       % (hidden_layer_size, input_layer_size+1)x(input_layer_size+1, 1)
  a2 = [1; sigmoid(z2)];  % = (hidden_layer_size+1, 1)
  z3 = Theta2 * a2;       % (num_labels, hidden_layer_size+1)x(hidden_layer_size+1, 1)
  a3 = sigmoid(z3);       % = (num_labels, 1)
  
  % step 2
  delta3 = a3 - Y(i,:)'; % (num_labels, 1)
  
  % step 3
  delta2 = ((Theta2' * delta3)(2:end) .* sigmoidGradient(z2));
          % (hidden_layer_size+1, num_labels)x(num_labels, 1) .* (hidden_layer_size, 1)
          % (hidden_layer_size, 1) [car on n'a pris que 2:end pour le premier vecteur]
  
  % step 4
  Delta2 += delta3 * a2';     % (num_labels, 1)x(1, hidden_layer_size+1)
                              % = (num_labels, hidden_layer_size+1)
  Delta1 += delta2 * a1';     % (hidden_layer_size, 1)x(1, input_layer_size+1)
                              % = (hidden_layer_size, input_layer_size+1)
  
endfor

% Step 5
Theta1_grad = Delta1 / m;
Theta2_grad = Delta2 / m;

% Regularization of gradients
Theta1_grad += lambda / m * [zeros(hidden_layer_size, 1) Theta1(:, 2:end)];
Theta2_grad += lambda / m * [zeros(num_labels, 1) Theta2(:, 2:end)];


% -------------------------------------------------------------

% =========================================================================

% Unroll gradients
grad = [Theta1_grad(:) ; Theta2_grad(:)];


end
