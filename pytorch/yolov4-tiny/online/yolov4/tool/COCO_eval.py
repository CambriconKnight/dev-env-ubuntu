from pycocotools.coco import COCO
from pycocotools.cocoeval import COCOeval
import json
import os

def calculateAp(resFile, annFile):
    annType = ['segm','bbox','keypoints']
    annType = annType[1]      #specify type here
    prefix = 'person_keypoints' if annType=='keypoints' else 'instances'

    #initialize COCO ground truth api
    cocoGt=COCO(annFile)

    cocoDt = cocoGt.loadRes(resFile)
    result = json.load(open(resFile, 'r'))
    imgIds = list()

    for res in result:
        if res['image_id'] not in imgIds:
            imgIds.append(res['image_id'])
    print('total image:{}'.format(len(imgIds)))
    
    # running evaluation
    cocoEval = COCOeval(cocoGt,cocoDt,annType)
    cocoEval.params.imgIds  = imgIds
    cocoEval.evaluate()
    cocoEval.accumulate()
    cocoEval.summarize()

    return round(cocoEval.stats[0], 3)
