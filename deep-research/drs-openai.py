import os
import pandas as pd
from openai import OpenAI
from dotenv import load_dotenv
from prompts.template import PromptTemplate
from utils import make_json, run_multithread_tqdm

load_dotenv()


deep_research_model = "o4-mini-deep-research"
N_BATCH = 5

class DeepResearchClient:
    def __init__(self, model: str = deep_research_model):
        self.model = model
        self.client = OpenAI(api_key=os.environ.get("OPENAI_API_KEY"))
        print(os.environ.get("OPENAI_API_KEY"))

    def create_response(self, prompt: str):
        response = self.client.responses.create(
            model=deep_research_model,
            input=prompt,
            tools=[
                {"type": "web_search_preview"},
            ],
        )
        return make_json(response.output[-1].content[0].text)


if __name__ == "__main__":
    drs_client = DeepResearchClient()
    final_results = []
    batch_prompts = []
    records = pd.read_csv("../data/science_data.csv")
    for i in range(0, len(records), N_BATCH):
        d = records[i:i+N_BATCH]
        prompt = PromptTemplate(template=open("prompts/prompt_citation.txt", "r").read(), input_variables=["records"])
        prompt = prompt.format(relationships=d)
        batch_prompts.append(prompt)
    batch_results = run_multithread_tqdm(drs_client.create_response, "Processing batch", batch_prompts)
    for result in batch_results:
        if result is not None:
            for r in result:
                if r is not None:
                    final_results.append(r)
    pd.DataFrame(final_results).to_csv("final_results.csv", index=False)    