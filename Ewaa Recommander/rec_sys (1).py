import numpy as np
import pandas as pd
from sklearn.preprocessing import LabelEncoder
from numpy.linalg import norm
from flask_cors import CORS,cross_origin
import json
from flask import Flask
from flask_restful import Resource,Api,reqparse,request
app = Flask(__name__)
api = Api(app)

class Recommender(Resource):
  def getSimilarity(data):
      encoder = 1
      encoder_dic = {}
      for p in data["basics_personality"]:
        encoder_dic[p] = encoder
        encoder = encoder + 1 
      maxPersLen = 0
      for k in data["personality"].keys():
        if maxPersLen<len(data["personality"][k]):
          maxPersLen = len(data["personality"][k])
      for k in data["personality"].keys():
          tmp_list = []
          for el in data["personality"][k]:
            tmp_list.append(encoder_dic[el])
            tmp_list = sorted(tmp_list)
          tmp_list.extend([0] * (maxPersLen - len(tmp_list)))
          data["personality"][k] = tmp_list
      data_personality = pd.DataFrame(data["personality"])
      similarity = {}
      for liked_id_el in data["liked_id"]:
        for col in data_personality.columns:
          if col not in data["liked_id"]:
            list1 = list(data_personality[liked_id_el])
            list2 = list(data_personality[col])
            tmp = [0] * len(list1)
            ind = 0
            for e in list1:
                if e in list2:
                    tmp[ind] = e
                ind = ind + 1
            ind = 0
            list2 = tmp
            sim = np.dot(list1,list2/norm(list1)*norm(list2))
            if liked_id_el in similarity.keys():
              similarity[liked_id_el].update({col:sim})
            else:
              similarity[liked_id_el] = {col:sim}
      final_similarity = {}
      maxSims = 0 
      for k in similarity.keys():
        for kk in similarity[k].keys():
          if similarity[k][kk]>maxSims:
            maxSims = similarity[k][kk]
            final_similarity[k] = kk
      final_similarity = list(set(final_similarity.values()))
      return final_similarity
  def post(self):
      data = request.get_json()
      similarity_pets = Recommender.getSimilarity(data)
      return {"similarity_pets":similarity_pets}
api.add_resource(Recommender,"/Recommender")
app.run()



