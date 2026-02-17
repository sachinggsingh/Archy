package customerror

type ErrorAtInput struct {
	Msg string
	Err error
}

func (e *ErrorAtInput) Error() string {

	if e.Err != nil {
		return e.Msg + ": " + e.Err.Error()
	}

	return e.Msg
}
