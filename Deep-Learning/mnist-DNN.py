# Tensorflow Deep Neural Net practice

python
# begin python

import tensorflow as tf
from tensorflow.examples.tutorials.mnist import input_data

########################### import data #########################################
mnist = input_data.read_data_sets("/tmp/data/", one_hot = True)
# one hot creates a binary (0,1) vector to classify tasks.




#### THIS IS A BACKGROUND TASK NOT INDEPENDENT, but SEPARATE from the Model. ####

# specify how many nodes are in each hidden layer.
n_nodes_hl1 = 500
n_nodes_hl2 = 500
n_nodes_hl3 = 500
# specify classes, we know this to be 10.
n_classes = 10
# we can train the entire network at once, but it is probably best to do in batches
batch_size = 100 # good practice for larger datasets.

# These are our placeholders for some values in our graph.
# [None, 784] is a second placeholder. Important to be explicit about the shape
x = tf.placeholder('float', [None, 784]) # TensorFlow will throw an error 
y = tf.placeholder('float') # if something out of shape attempts to hop into that variable's place.



####################### Beginning stages, nn model. ################################

def neural_network_model(data):
  hidden_1_layer = {'weights':tf.Variable(tf.random_normal([784, n_nodes_hl1])),
  'biases':tf.Variable(tf.random_normal([n_nodes_hl1]))} # biases are specified as random normal for now.
  hidden_2_layer = {'weights':tf.Variable(tf.random_normal([n_nodes_hl1, n_nodes_hl2])),
  'biases':tf.Variable(tf.random_normal([n_nodes_hl2]))}
  hidden_3_layer = {'weights':tf.Variable(tf.random_normal([n_nodes_hl2, n_nodes_hl3])),
  'biases':tf.Variable(tf.random_normal([n_nodes_hl3]))}
  output_layer = {'weights':tf.Variable(tf.random_normal([n_nodes_hl3, n_classes])),
  'biases':tf.Variable(tf.random_normal([n_classes]))}
  # takes hidden layer one, does a matrix multiplication, then passes it to the next layer
  l1 = tf.add(tf.matmul(data,hidden_1_layer['weights']), hidden_1_layer['biases'])
  l1 = tf.nn.relu(l1)
  # tf.add is just adding the bias.
  l2 = tf.add(tf.matmul(l1,hidden_2_layer['weights']), hidden_2_layer['biases'])
  l2 = tf.nn.relu(l2)
  
  l3 = tf.add(tf.matmul(l2,hidden_3_layer['weights']), hidden_3_layer['biases'])
  l3 = tf.nn.relu(l3)
  # final layer is then multiplied with the addition of the output biases and weights.
  output = tf.matmul(l3,output_layer['weights']) + output_layer['biases'] 
  
  return output

############################ Training process for model. ##############################


def train_neural_network(x):
  prediction = neural_network_model(x)
  # loss function
  cost = tf.reduce_mean( tf.nn.softmax_cross_entropy_with_logits(logits=prediction, labels=y) )
  optimizer = tf.train.AdamOptimizer().minimize(cost) # use adam. learning_rate = 0.001 (default)
  hm_epochs = 10 # how many times to run back again (cycles of feed forward and back prop)
  
  with tf.Session() as sess:
    sess.run(tf.global_variables_initializer()) # initialize tensor global variables.
    
    for epoch in range(hm_epochs): # epoch for loop.
      epoch_loss = 0
      for _ in range(int(mnist.train.num_examples/batch_size)):
        epoch_x, epoch_y = mnist.train.next_batch(batch_size)
        _, c = sess.run([optimizer, cost], feed_dict={x: epoch_x, y: epoch_y})
        epoch_loss += c
  
    print('Epoch', epoch, 'completed out of',hm_epochs,'loss:',epoch_loss)
    
    # scoring..
    correct = tf.equal(tf.argmax(prediction, 1), tf.argmax(y, 1)) # how many predictions matched labels.
    accuracy = tf.reduce_mean(tf.cast(correct, 'float')) 
    print('Accuracy:',accuracy.eval({x:mnist.test.images, y:mnist.test.labels}))


train_neural_network(x)

