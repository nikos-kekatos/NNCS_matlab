#%%
import numpy as np
import matplotlib.pyplot as plt
from keras.layers import Dense, Activation
from keras.models import Sequential
from sklearn.model_selection import train_test_split
import matplotlib.pyplot as plt
import pandas as pd
import time
#%% Import the dataset
# pandas
#breakpoint()
#filename='data_keras_30_traces_1_block.txt'
filename='data_hespanha_v1.txt'
#t1_start=time.time()
#data = pd.read_csv(filename,header=0)
#type(data)
#data.head
#print(data.shape)
#t1_end=time.time()
#%%%
#dataset=data.to_numpy()

# numpy
t2_start=time.time()
data = np.genfromtxt(filename, delimiter=',')
type(data)
print(data.shape)
t2_end=time.time()


X=data[:,:-1]
y=data[:,-1:]
print(X.shape)
print(y.shape)
model_type=1

print('The numpy took ',t2_end-t2_start,'\n')

# %%

# Splitting the dataset into the Training set and Test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.1, random_state = 0) #.08

# Feature Scaling
from sklearn.preprocessing import StandardScaler
sc = StandardScaler()
#X_train = sc.fit_transform(X_train)
#X_test = sc.transform(X_test)
#y_train = sc.fit_transform(y_train)
#y_test = sc.transform(y_test)

#%%
'''
from sklearn.preprocessing import MinMaxScaler
#sc = StandardScaler()
#X=sc.transform(X)
#y=sc.transform(y)
scaler_x = MinMaxScaler()
scaler_y = MinMaxScaler()
print(scaler_x.fit(X))
X=scaler_x.transform(X)
print(scaler_y.fit(y))
y=scaler_y.transform(y)

# Splitting the dataset into the Training set and Test set
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size = 0.15, random_state = 0) #.08
'''
#%%
# Initialising the ANN
model = Sequential()

model.add(Dense(units=40, activation = 'tanh', input_dim = X_train.shape[1]))
model.add(Dense(units = 20, activation = 'tanh'))
#model.add(Dense(units = 32, activation = 'tanh'))
model.add(Dense(units = y_train.shape[1], activation='linear'))

# Compiling the ANN
#model.compile(optimizer=keras.optimizers.Adam(lr=0.001), loss = 'mse',metrics=['mse','mae'])
model.compile(optimizer='adam', loss = 'mae',metrics=['mse','mae',"accuracy"])

# Fitting the ANN to the Training set
history=model.fit(X_train, y_train, batch_size = 1000, epochs = 10000,validation_split=0.2)#,validation_data = (y_train,y_test))

y_pred = model.predict(X_test)
test_loss = model.evaluate(X_test,y_test)

plt.plot(history.history['mse'])
plt.plot(history.history['mae'])
plt.show()

print(history.history.keys())
# "Loss"
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'validation'], loc='upper left')
plt.show()

for i in range(y_pred.shape[1]):
    plt.plot(y_test[:,i], marker='o', linestyle="None",color = 'red', label = 'Real data')
    plt.plot(y_pred[:,i], marker='x',linestyle="None",color = 'blue', label = 'Predicted data')
    plt.title('Prediction')
    plt.legend()
    plt.show()


y_pred_all = model.predict(X_train)
for i in range(y_pred.shape[1]):
    plt.plot(y_train[:,i], marker='o', linestyle="None",color = 'red', label = 'Real data')
    plt.plot(y_pred_all[:,i], marker='x',linestyle="None",color = 'blue', label = 'Predicted data')
    plt.title('Prediction')
    plt.legend()
    plt.show()

#model.save("keras_nn_7",save_format="h5")
model.save("keras_nn_hespanha_v6.h5")

# %%
print("end")
