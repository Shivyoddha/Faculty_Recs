class CreditAnswersController < ApplicationController
  before_action :set_credit_answer, only: %i[ show edit update destroy ]

  # GET /credit_answers or /credit_answers.json
  def index
    @credit_answers = CreditAnswer.all
  end

  # GET /credit_answers/1 or /credit_answers/1.json
  def show
  end

  # GET /credit_answers/new
  def new
    puts "Reached the new action"
    @form = Form.find(params[:id])
    @user = User.find(params[:userid])
    @section = CreditSection.all
    @questions = CreditQuestion.all
    @answers = @questions.map { |question| CreditAnswer.new(credit_question_id: question.id) }
  end

  # GET /credit_answers/1/edit
  def edit
  end

  # POST /credit_answers or /credit_answers.json
  def create
    @questions = CreditQuestion.all
    answer_params_array = params[:answers][:answers]

    response = Response.create!

    parameter_value = params[:answers][:entry]
    response.form_id = parameter_value

    @answers = []
    credit = 0

    answer_params_array.each do |answer_param|
      permitted_params = answer_param.permit(:answer, :credit_question_id,:response_id, :file_upload)
      answer = CreditAnswer.new(permitted_params)
      if answer.answer == nil
        answer.answer =0
      end

      #credit calculations
      if answer.credit_question.obt_credit * answer.answer >  answer.credit_question.max_credit
        credit = credit + answer.credit_question.max_credit
      else
         credit = credit + answer.credit_question.obt_credit * answer.answer
      end
      answer.response_id = response.id
      @answers << answer
    end

    response.credit_score = credit
    response.user_id = current_user.id
    form_id = response.form_id
    @form = Form.find(form_id)

    if credit >= @form.credit_req
      response.save
      if @answers.all? { |answer| answer.valid? }
        @answers.each(&:save)
        redirect_to submit_form_form_path(userid: current_user.id, id: @form.id), notice: 'Answers were successfully created.'
      else
        render :new
      end
    else
      redirect_to new_credit_answer_path(id: @form.id,userid: current_user.id)
      response.destroy
    end
  end

  # PATCH/PUT /credit_answers/1 or /credit_answers/1.json
  def update
    respond_to do |format|
      if @credit_answer.update(credit_answer_params)
        format.html { redirect_to credit_answer_url(@credit_answer), notice: "Credit answer was successfully updated." }
        format.json { render :show, status: :ok, location: @credit_answer }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @credit_answer.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /credit_answers/1 or /credit_answers/1.json
  def destroy
    @credit_answer.destroy

    respond_to do |format|
      format.html { redirect_to credit_answers_url, notice: "Credit answer was successfully destroyed." }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_credit_answer
      @credit_answer = CreditAnswer.find(params[:id])
    end

    # Only allow a list of trusted parameters through.
    def credit_answer_params
      params.require(:credit_answer).permit(:answer, :credit_question_id, :entry, :response_id, :file_upload, :credit_section_id)
    end
end
