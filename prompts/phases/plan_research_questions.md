# Phase: plan_research_questions

## Mission
Convert the round risk and scope into structured research questions. Each question must bind to a specific risk and claim, specify the expected evidence type, and define success and failure conditions. At least one question must target weakening or contradicting evidence.

## Inputs
- `round-risk.yaml`
- `round-scope.yaml`

## Outputs
- `research-questions.yaml`

## Allowed Actions
- Read round-risk and round-scope.
- Formulate at least 3 research questions.
- Bind each question to a specific risk and claim.
- Define evidence type expectations.
- Define what constitutes failure to find evidence.

## Forbidden Actions
- Do not execute searches.
- Do not claim evidence has been found.
- Do not critique the paper.
- Do not write evidence-ledger.

## Procedure
1. For each in-scope claim, formulate questions that would strengthen or weaken it.
2. Ensure each question has: linked_risk, linked_claims, expected_evidence_type.
3. Define failure_condition: what does it mean if no evidence is found?
4. Define success_condition: what evidence would satisfy this question?
5. Ensure at least one question explicitly targets weakening/contradicting evidence.
6. Generate at least 3 questions total.

## Output Contract
```yaml
questions[*]:
  question_id: string
  linked_risk: string
  linked_claims: [claim_id, ...]
  question: string (>=10 chars)
  expected_evidence_type: string
  failure_condition: string (>=5 chars)
  success_condition: string
```
Minimum 3 questions. At least one failure_condition must indicate search for counterevidence.

## Failure Conditions
- Fewer than 3 questions.
- Any question has no linked_claims.
- No question targets weakening/contradicting evidence.
- Any question text <10 chars.

## Knowledge Use
Cite loaded knowledge cards with intended_use including `plan_research_questions`.

## Handoff
`generate_search_strategy` will convert these questions into concrete search queries.
