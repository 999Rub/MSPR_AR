import numpy as np
import os

from tflite_model_maker.config import ExportFormat
from tflite_model_maker import model_spec
from tflite_model_maker import object_detector

import tensorflow as tf
assert tf.__version__.startswith('2')

tf.get_logger().setLevel('ERROR')
from absl import logging
logging.set_verbosity(logging.ERROR)

spec = model_spec.get('efficientdet_lite0')

train_data = object_detector.DataLoader.from_pascal_voc('images/train', 'images/train',['Singe'])
validation_data = object_detector.DataLoader.from_pascal_voc('images/test', 'images/test', ['Singe'])
model = object_detector.create(train_data, model_spec=spec, epochs=80, batch_size=8, train_whole_model=True, validation_data=validation_data)
model.evaluate(validation_data)
model.export(export_dir='.')
model.evaluate_tflite('model.tflite', validation_data)
