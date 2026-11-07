package inference

import (
	"context"
	"fmt"
	"strings"
)

type ModelDocument struct {
	Service   string
	Model     string
	Resources string
}

type ModelLoader interface {
	LoadModel(ctx context.Context, service string) (string, error)
}

type Bundle struct {
	ID    string
	Input []byte
}

type BundleRenderer interface {
	RenderBundles(ctx context.Context, template string, doc ModelDocument) ([]Bundle, error)
}

type Task struct {
	JobName      string
	ID           string
	Input        []byte
	Prompt       string
	OutputSchema []byte
}

type Job interface {
	Name() string
	Build(ctx context.Context, doc ModelDocument, previous Results) ([]Task, error)
}

type OutputTransformer interface {
	TransformOutput(task Task, output []byte) ([]byte, error)
}

type OutputValidator interface {
	ValidateOutput(ctx context.Context, task Task, output []byte) ([]byte, []string, error)
}

type Results map[string]string

type Rejection struct {
	JobName  string
	TaskID   string
	Problems []string
}

type Runner interface {
	Exec(ctx context.Context, task Task) ([]byte, error)
}

type Store interface {
	Load(jobName string, taskID string) ([]byte, bool, error)
	Save(jobName string, taskID string, output []byte) error
	LoadAll(jobName string) (string, error)
}

type Progress func(jobName, taskID string, cached bool)

type Pipeline struct {
	Jobs     []Job
	Runner   Runner
	Store    Store
	Force    bool
	Limit    int
	Progress Progress
}

func (p Pipeline) Exec(ctx context.Context, doc ModelDocument) (Results, []Rejection, error) {
	results := Results{}
	var rejections []Rejection
	for _, job := range p.Jobs {
		tasks, err := job.Build(ctx, doc, results)
		if err != nil {
			return nil, nil, err
		}
		count := 0
		for _, task := range tasks {
			if !p.Force {
				_, ok, err := p.Store.Load(job.Name(), task.ID)
				if err != nil {
					return nil, nil, err
				}
				if ok {
					if p.Progress != nil {
						p.Progress(job.Name(), task.ID, true)
					}
					continue
				}
			}
			if p.Progress != nil {
				p.Progress(job.Name(), task.ID, false)
			}
			output, problems, err := p.execTask(ctx, job, task)
			if err != nil {
				return nil, nil, err
			}
			count++
			if len(problems) > 0 {
				rejections = append(rejections, Rejection{JobName: job.Name(), TaskID: task.ID, Problems: problems})
			} else {
				err = p.Store.Save(job.Name(), task.ID, output)
				if err != nil {
					return nil, nil, err
				}
			}
			if p.Limit > 0 && count >= p.Limit {
				break
			}
		}
		all, err := p.Store.LoadAll(job.Name())
		if err != nil {
			return nil, nil, err
		}
		results[job.Name()] = all
	}
	return results, rejections, nil
}

func (p Pipeline) execTask(ctx context.Context, job Job, task Task) ([]byte, []string, error) {
	output, err := p.attempt(ctx, job, task)
	if err != nil {
		return nil, nil, err
	}
	validator, ok := job.(OutputValidator)
	if !ok {
		return output, nil, nil
	}
	valid, problems, err := validator.ValidateOutput(ctx, task, output)
	if err != nil || len(problems) == 0 {
		return valid, nil, err
	}
	if p.Progress != nil {
		p.Progress(job.Name(), task.ID+" (retry)", false)
	}
	retry := task
	retry.Prompt = retryPrompt(task.Prompt, output, problems)
	output, err = p.attempt(ctx, job, retry)
	if err != nil {
		return nil, nil, err
	}
	return validator.ValidateOutput(ctx, task, output)
}

func (p Pipeline) attempt(ctx context.Context, job Job, task Task) ([]byte, error) {
	output, err := p.Runner.Exec(ctx, task)
	if err != nil {
		return nil, err
	}
	if transformer, ok := job.(OutputTransformer); ok {
		return transformer.TransformOutput(task, output)
	}
	return output, nil
}

func retryPrompt(prompt string, output []byte, problems []string) string {
	var b strings.Builder
	b.WriteString(prompt)
	b.WriteString("\nA previous attempt returned the output below, which failed validation against input.json. Return a corrected result; drop any entry you cannot correct.\n\nProblems:\n")
	for _, problem := range problems {
		fmt.Fprintf(&b, "- %s\n", problem)
	}
	fmt.Fprintf(&b, "\nPrevious output:\n\n```json\n%s\n```\n", strings.TrimSpace(string(output)))
	return b.String()
}
