from tqdm import tqdm
from threading import Thread
import json


N_TRIES = 1


def make_json(response: str):
    res = response.replace("```json", "").replace("```", "")
    try:
        return json.loads(res.replace("'", '"'))
    except:
        try:
            return json.loads(res)
        except:
            return None


def run_multithread_tqdm(func, desc, *inputs):
    arg_list = list(zip(*inputs))
    results = [None] * len(arg_list)
    threads = []

    def process(index, f, f_args):
        for attempt in range(1, N_TRIES + 1):
            try:
                results[index] = f(*f_args)
                break
            except Exception as e:
                print(e)
                if attempt == N_TRIES:
                    results[index] = None
    
    for idx, args in enumerate(arg_list):
        t = Thread(target=process, args=(idx, func, args))
        threads.append(t)
        t.start()

    for t in tqdm(threads, desc=desc):
        t.join()

    return results