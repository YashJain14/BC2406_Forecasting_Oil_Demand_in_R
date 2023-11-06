Table of Contents

1.	Executive Summary     ・・・・・・・・・・・・・・・・・・・・・・・              1
2.	Introduction     ・・・・・・・・・・・・・・・・・・・・・・・・・・              2
2.1 Background of Aramco
2.2 Problem Statement and Purpose
3.	Results     ・・・・・・・・・・・・・・・・・・・・・・・・・・・・・     3
3.1 Data Exploration
3.2 Model
4. Discussion     ・・・・・・・・・・・・・・・・・・・・・・・・・・・・         13
4.1 Application to Business Outcomes
4.2 Limitations
5. Conclusion     ・・・・・・・・・・・・・・・・・・・・・・・・・・・            17
6. Appendices     ・・・・・・・・・・・・・・・・・・・・・・・・・・・           18


 
1. EXECUTIVE SUMMARY
Aramco saw impressive financial growth in 2022 but faced a 19% drop in net income in early 2023 due to fluctuating oil demand influenced by various factors. To address the challenge of fluctuating demand, we aim to develop a machine learning model to forecast monthly oil demand. This model will enhance decision-making and help Aramco adapt to changing market dynamics while aligning with its climate change commitments.
To develop these models, we used publicly available crude oil export data from Saudi Arabia as a metric for total demand from Aramco’s customers. To forecast oil exports from Saudi Arabia, we applied linear regression, Vector AutoRegression (VAR), and Long Short-Term Memory (LSTM) models. The variables used in predicting oil exports are Saudi Arabia’s oil production, oil exchange open price, oil trading volume, Aramco’s stock price, geopolitical influences, and crude oil imports to China, India, Japan, the USA, and Korea.
A key finding from the datasets we analysed was that the GDP growth rates of large economies like India and China were positively correlated with global demand for oil. We further learnt that high oil demand was correlated to high oil prices and high Aramco stock prices.
The machine learning models we developed are a Proof of Concept for Aramco to consider. They have been shown via testing to be reasonably good predictors of oil demand. The implementation and further refinement of these models would result in several positive business outcomes. Accurate demand prediction would increase Aramco’s operational efficiency, reduce oil price volatility, and enhance decision-making. 
Aramco should also address the limitations of the models and adapt them according to their goals and needs to enhance their value and effectiveness in improving Aramco’s business outcomes.
2. INTRODUCTION
2.1 Background Information
Saudi Arabian Oil Group, or Aramco, is a global company with a significant presence in the energy and chemicals sector, adding value throughout the entire hydrocarbon chain (Aramco, n.d.).
Financial highlights for 2022 reveal a substantial increase in net income, reaching a record $161.1 billion in 2022, marking a 46.5% growth compared to the previous year when it was $110.0 billion. This significant rise can be attributed to higher crude oil prices, increased sales volumes, and improved profit margins for refined products. Notably, the net income for the fourth quarter of 2022 aligned with analysts' expectations, excluding certain non-cash items totalling approximately $3.3 billion (Dhahran, 2023).
Operational highlights for 2022 included maintaining an average hydrocarbon production of 13.6 million barrels of oil equivalent per day, with 11.5 million barrels per day consisting of total liquids. Aramco continued to demonstrate a remarkable 99.9% reliability in the delivery of crude oil and other products, marking the third consecutive year at this level of reliability (Dhahran, 2023).
However, despite being the second-largest public company in the world, Saudi Aramco experienced a 19% drop in net income in the first quarter of 2023 (Simon, 2023). The drop in the profit is due to an increase in oil production coupled with a drop in demand. These market forces are, in turn, affected by various factors such as economic outlook, geopolitical events, and inventory levels.
Furthermore, due to the recent heightened emphasis on climate change, Aramco has pledged to reduce its carbon footprints, and one of the possible ways is to minimise its oil production. However, such a decision would affect its profit. Thus, Aramco needs to identify the amount of oil required and reduce its oil production to just below the required demand to drive up the price and compensate for revenue lost due to a decrease in oil production (Joe Middleton, 2023).

2.2 Problem Statement and Purpose
Aramco faces challenges in optimising its oil production and distribution due to fluctuations in global oil demand. These fluctuations are influenced by various factors, such as economic conditions, geopolitical events, and inventory levels. Should they not maximise their oil production and distribution, they are likely to lose profit. To enhance its decision-making processes, we aim to develop a machine-learning model that forecasts monthly oil demand. 

3. RESULTS
3.1 Data Exploration
To develop a machine learning model that predicts the monthly oil demand, we have gathered numerous publicly available datasets and tried to explain abnormal phenomena and establish a relationship between various factors and how they affect the oil demand. 

 
Fig. 1: Plot of Monthly Price of Crude Oil 
 
Fig. 2: Plot of Average Rating of News Headlines against Time
Figure 2 depicts the time-series plot illustrating the average rating of news headlines. This rating was generated through a sentiment analysis of news headlines related to the oil industry. The headlines are rated on a scale from 1 to 10, with 1 indicating a negative influence on Aramco and 10 indicating a positive influence. We incorporated sentiment analysis into our model due to the oil market's susceptibility to price volatility caused by external shocks. Research by Li et al. in 2016 demonstrates that sentiment regarding oil price trends, extracted from pertinent online information about oil markets, serves as a robust predictor of oil prices. This is further underscored by the comparative analysis of the similarities between Figure 1 and Figure 2.
The sentiment analysis of geopolitical events is conducted using LLM (GPT-3.5) because it possesses a deeper understanding of the events than merely examining words in news headlines.

 
Fig. 3: Plot of Trade Volume of Crude Oil against Time

 
Fig. 4: Plot of Crude Oil Import by India against Time

 
Fig. 5: Plot of Crude Oil Import by China against Time
The Russia-Ukraine war (Feb-2022) led to a spike in global oil prices, affecting oil imports by India and China. Amid high prices, China's oil imports dipped in April 2022 from a high in March 2022, while India saw a decrease in oil imports from July 2022 to September 2022. The war-induced price surge thus resulted in reduced trade volumes of crude oil, reflecting the economic pressure on major Asian importers (Reuters, 2023). This indicates that the rise in crude oil prices can have a negative effect on trade volume and imports of large economies like China and India.
 
Fig. 6: Plot of Crude Oil Export by Saudi Arabia against Time
The huge rise and subsequent dip in Saudi Arabia's crude oil exports in 2020, shown in Figure 6, can be attributed to market dynamics affected by the COVID-19 pandemic. Early in 2020, the onset of the pandemic drastically reduced global demand for oil due to widespread lockdowns and travel restrictions, leading to an initial drop in prices. In response to the low demand, a price war ensued when Saudi Arabia decided to increase production to maintain market share after Russia disagreed with making production cuts. This caused a temporary surge in oil exports, reflected in the peak.
However, this was followed by a sharp decline as OPEC+ agreed to cut oil production in an effort to stabilise the market. The significant dip in the graph corresponds with these production cuts as the countries worked to balance supply with the reduced demand and prevent a further collapse in oil prices.
 
Fig. 7: Heatmap of Correlation between Variables
We have plotted a heatmap of the correlation between variables to help us identify their relationship, which then helps us decide on the data we should feed our prediction model.
●	There is a strong correlation between global oil consumption and India's GDP, indicating that as India's economy grows, its demand for oil increases significantly.
●	The price of oil shows a correlation with both global consumption levels and the stock price of Saudi Aramco. This suggests that as demand for oil rises, oil prices tend to increase, which in turn may have a positive effect on the stock price of one of the world's largest oil companies.
●	The GDP of Saudi Arabia is positively correlated with geopolitical events, implying that the economic health of the country is significantly influenced by the political stability and events in the region or globally that affect the oil market.
●	Trade volume is negatively correlated with oil prices and the stock price of Saudi Aramco, suggesting that as oil prices rise, trade volumes tend to decrease, which could be due to a variety of factors, including market saturation, reduced demand at higher price points, or increased market caution.
 
Fig. 8: Box Plot of Trade Volume by Month
The dip shown in the box plot (Figure 6) is largely because of the OPEC+ agreement, where the involved countries agree to cut oil production to drive the price of oil up. (Bromberg, 2023). Due to the drastic drop in the price of oil in March, companies are not profiting much (U.S. Energy Information Administration, 2023). By reducing oil production, trade volume decreases, and due to supply and demand forces, the price of oil increases. Other factors causing a drop in trade volume are likely due to a warm climate and weak industrial activity.

3.2 Prediction Models
We used Linear Regression, Vector AutoRegression (VAR), and Long Short-Term Memory (LSTM) models to predict monthly crude oil exports from Saudi Arabia (in Thousand Barrels/Day). Additionally, we used exports as a measure of the total demand for Aramco’s crude oil by its customers. The key findings and insights are summarised below. Detailed descriptions of the models used are provided in appendices 1, 2, and 3.
Linear Regression
We conducted a linear regression analysis with oil exports serving as the dependent variable. The independent variables included in the model were trading volume and oil imports from China, Japan, India, and the United States, with a particular focus on US imports from Saudi Arabia. A detailed examination (refer to Appendix 1) of the predictive validity of these variables indicated that trading volume, Japan's oil imports, and US oil imports from Saudi Arabia are statistically significant predictors of oil export volumes.

 
Fig. 9: Prediction of Oil Export from linear regression model

It can be observed that the model captures the general trend of the exports, despite some discrepancies at certain points. Notably, a significant spike in the actual exports around early 2020 is not mirrored in the predictions, which may suggest the presence of black swan events or unmodeled factors affecting exports during that period.
Vector Autoregression
Building on the insights gained from the simple linear regression analysis, we proceeded to implement a Vector Autoregression (VAR) model with a lag order of 5 (i.e. 5 months). The VAR model is a multivariate forecasting algorithm that captures the linear interdependencies among multiple time series.
 
Fig. 10: Prediction of Oil Export from VAR (5 months) model

The graph clearly demonstrates that the integration of historical data points from the time series markedly improves the predictive accuracy of the model. Our detailed analysis, which can be found in Appendix 2, indicates that future oil export figures are closely linked to past values of trading volume, US imports from Saudi Arabia, and the historical export numbers themselves.
VAR Model Prediction
Figure 9 presents the forecast for oil exports over a one-year period, utilising the VAR model with five lags (VAR(5)). According to the model's projections, oil exports are expected to increase to approximately 6,600 thousand barrels per day by 2024. The shaded area in the figure represents the predictive uncertainty, which expands with the extension of the forecast horizon. Given this increasing uncertainty over time, it is crucial to regularly refine the model with up-to-date data and to primarily employ the model for short-term forecasting purposes.
 

Fig. 11: Oil Export Forecast from VAR (5 months) model
Long Short Term Memory (LSTM)
We decided to develop another model based on neural networks. Generally, the performance of neural network models in making accurate predictions can be enhanced with the inclusion of more layers and an increase in data points. As the dataset comprises time series data, a Long Short-Term Memory (LSTM) model was implemented to forecast monthly oil exports. The LSTM architecture is designed to model temporal sequences and long-term dependencies in time series data, which is suitable in this case where data are dependent on historical value and other variables.
The LSTM model was developed using the Keras deep learning library. The model takes in the past 12 months of data (n_past = 12) to predict exports for the next month’s value. A total of 20 input features were used, including trading volumes, oil imports, sentiment scores and other relevant predictors. 
Below is the plot that shows the actual exports compared to the LSTM model's predictions over time to visually assess how the predictions match up with reality.

 
Fig. 12: Plot of Actual and Forecasted Exports against Time

4. DISCUSSION
4.1 Application to Business Outcomes
The model results would be utilised by Aramco’s staff as a component in their decision-making process to determine pricing and business decisions that achieve business goals, such as maximising profit, increasing market share, or minimising cost. Accurate oil demand predictions would result in several positive business outcomes. The model would increase operational efficiency, reduce price volatility, and enhance decision-making. Accurate forecasting to optimise operations is crucial for Aramco, given the long-term challenges of increased adoption of green technology and depleting oil reserves as possible threats to its profits (Alzubair, 2021).
Firstly, accurate demand prediction would ensure smoother operations and increase operational efficiency, as Aramco could adjust factor inputs needed for production in advance. For example, if Aramco predicts demand for petroleum products to increase significantly, it could divert resources from other products to increase the production and yield of petroleum and related products. Staff working on the production of these products and distribution capacity could also be increased in advance to meet the predicted oil demand. These measures would allow operations to continue efficiently with minimal disruption. Aramco’s production levels would also match market demand, minimising shortages or surpluses. Consequently, excess storage and warehousing costs can be reduced, and processes can be optimised to increase efficiency and minimise wastage.
In addition, our model can aid Aramco in stabilising oil prices. Oil and gas prices are highly volatile, especially in periods of economic uncertainty. Oil price volatility has been shown to decrease firm profitability significantly (Bugshan et al., 2023). Moreover, excessive oil price volatility has historically had a negative impact on the oil-dependent Saudi Arabian economy (Jawadi & Ftiti, 2019). Thus, Saudi Arabia has a strong interest in maintaining high crude oil prices through the state-owned company Aramco, even if it requires a decrease in its production. This strategy relies on market data, such as world crude oil demand and prices (Dagoumas et al., 2018). Forecasting demand accurately using a machine learning model allows Aramco to anticipate changes in demand for oil and adjust its output to reduce oil price volatility to reap consistently high profits.
Accurately predicting demand is also essential for companies to make plans (Tugay & Oguducu, 2020). Implementing a machine learning model would allow Aramco to enhance its decision-making and adjust production levels to optimal levels. According to economic theory, a rational firm would produce goods at the profit-maximising output, where the marginal cost of production is equal to the marginal revenue for one unit of production (Levitt, 2016). Our model would help Aramco determine the quantity of output that would maximise Aramco’s profits. This is shown by output level Q1 in Fig. 11, which gives the largest profit level, represented by the area labelled ‘Supernormal profit’.

 
Fig. 13: Visual representation of profit-maximising output, at the intersection of the MR and MC curves (MR=MC) (Edexcel Economics Revision. 2018)

Moreover, our model can help Aramco predict future sales and cash flow more accurately and guide investment decisions accordingly. It can also help forecast operational costs, which would be useful for future production planning and budgeting.

4.2 Limitations
The models used in this analysis primarily focus on historical trading volumes, oil imports from specific countries, and past export data. As a result, these models could be limited in effectiveness as they do not take into consideration other variables that could significantly affect oil demand, such as changes in energy and environmental policies by governments, currency exchange rates and new technological developments. 
Furthermore, the models used could be over-reliant on historical data, without considering real-time data adequately. Oil demand could be affected significantly by sudden and unforeseen events, such as geopolitical tensions, natural disasters, or pandemics. Not incorporating real-time data in prediction models could lead to inaccurate forecasts, especially during unusual or "black swan" events or times of significant market shifts.
These limitations highlight the need for Aramco to adapt and optimise these machine learning models to fit their goals and needs. They can enhance the effectiveness of these models by integrating additional input data and variables that they could have collected for their use, which are not publicly available. The models can be further refined by incorporating real-time data and conducting scenario analysis and stress testing to determine their effectiveness. Using feedback loops that allow experts to continuously validate predictions against actual outcomes and make necessary adjustments will increase the accuracy and therefore, value to Aramco. Additionally, domain experts with extensive knowledge of the oil markets should be consulted as well, as part of Aramco’s decision-making process, to account for variables and intangibles that machine learning prediction models may not be able to capture fully. Ultimately, the models should be used to gain insights and in conjunction with human decision-makers, rather than making the decisions on their own.
It should also be noted that models are built on certain assumptions that might not be true in all scenarios. For example, the VAR model assumes linear interdependencies among the selected time series variables. These assumptions may not accurately reflect the complex and dynamic nature of oil demand, which can be influenced by non-linear and interrelated factors.


5. CONCLUSION
The analysis and modelling presented in this report offer valuable insights into the factors influencing oil demand and the potential benefits for Aramco’s decision-making process. The application of predictive models to Aramco’s business outcomes is promising. Accurate oil demand prediction can result in a range of positive outcomes, including increased operational efficiency and reduced price volatility. The model can assist Aramco in stabilising oil prices, which is essential given the volatility of the oil and gas market. Consistently high profits can be achieved by pre-empting changes in oil demand and adjusting output accordingly. Furthermore, the model can aid Aramco in predicting future sales, cash flow, and operational costs, guiding investment decisions and production planning. However, it is essential to acknowledge and address the limitations of the model, in order to further refine them to be more accurate and effective in producing desirable outcomes.



 
6. APPENDICES
Appendix 1: Data Exploration
 
Plot of GDP Growth Rate against Time
 
 Plot of Crude Oil Production by Saudi Arabia against Time
 
Plot of US Import from Saudi Arabia against Time
 
Plot of Saudi Aramco Stock Price (SAR) over Time
 
Plot of Global Crude Oil Production over Time
 
Plot of Global Crude Oil Consumption over Time


Appendix 2: Description of Linear Regression Model

 
 
Prediction of Oil Export from linear regression model
The RMSE of this model is 601.5 thousand barrels/day. The R2 is 0.5562.

Appendix 3: Description of Vector Autoregression Model
  
Prediction of Oil Export from VAR (5 months) model
The RMSE of this model is 165.975 thousand barrels/day. The R2 is 0.9511.

Appendix 4: Description of Long Short-Term Memory (LSTM) Model
An LSTM model is a type of recurrent neural network (RNN) specifically designed to learn order dependence in sequence prediction problems. This is particularly useful in time series forecasting, where classical linear models might struggle to capture complex patterns.
The dataset contains data that track oil exports and other related economic variables over time. Using an LSTM model for such data is beneficial because:
●	Temporal Patterns: LSTMs can capture the temporal patterns and dependencies that are characteristic of time series data, such as trends and seasonal variations in oil exports.
●	Variable Influences: They can potentially learn which factors (like production levels, geopolitical ratings, world production, and consumption) are most predictive of future exports.
●	Non-linearity: LSTMs can model the non-linear relationships that are often present in economic and financial time series data.
●	Data Integrity Over Time: LSTMs can maintain and manipulate information over long periods, which is crucial for maintaining the integrity of time-dependent data.
The evaluation process include:
Loss Metrics:
Root Mean Squared Error (RMSE): The square root of the MSE, which scales the errors back to the original units of the output variable and is easier to interpret.

Goodness of Fit:
R-squared (R²): Represents the proportion of the variance for the dependent variable that's explained by the independent variables in the model. In the context of LSTM, it would show how well the past values and other features explain the variance in oil exports.

 
RMSE and R-squared values of LSTM model

 
REFERENCES
Alzubair, A. (2021). The Need for Economic Diversification in the Oil-Dependent Nations of Saudi Arabia, UAE, and Nigeria: Possible Pathways and Outcomes.
Aramco. (n.d.). Who are we. Overview. Energy security for a sustainable world. https://www.aramco.com/en/who-we-are/overview
Bromberg, M. (2023, April 19). OPEC’s influence on global oil prices. Investopedia. https://www.investopedia.com/ask/answers/060415/how-much-influence-does-
opec-have-global-price-oil.asp
Bugshan, A., Bakry, W., & Li, Y. (2023). Oil price volatility and firm profitability: an empirical analysis of Shariah-compliant and non-Shariah-compliant firms. International Journal of Emerging Markets, 18(5), 1147-1167. https://doi.org/10.1108/IJOEM-10-2020-1288 
Dagoumas, A., Perifanis, T., & Polemis, M. (2018). An econometric analysis of Saudi Arabia's crude oil strategy. Resources Policy, 59, 265-273. https://doi.org/10.1016/j.resourpol.
2018.07.013
Dhahran. (2023). Aramco announces record full-year 2022 results. https://www.aramco.com/en/news-media/news/2023/aramco-announces-full-year-2022-results
Edexcel Economics Revision. (2018, October 27). Business objectives. https://edexceleconomicsrevision.com/home/theme-3-business-behaviour-and-the-labour-market/business-objectives/
Jawadi, F., & Ftiti, Z. (2019). Oil price collapse and challenges to economic transformation of Saudi Arabia: A time-series analysis. Energy Economics, 80, 12-19. https://doi.org/10.1016/j.eneco.2018.12.003
Johnston, M. (2022, February 22). What happened to oil prices in 2020. Investopedia. https://www.investopedia.com/articles/investing/100615/will-oil-prices
-go-2017.asp
Kennedy, C. (2022, August 17). Natural gas demand outpaces production. OilPrice.com. https://oilprice.com/Energy/Natural-Gas/Natural-Gas-Demand-
Outpaces-Production.html
Levitt, S. D. (2016). Bagels and donuts for sale: A case study in profit maximization. Research in Economics, 70(4), 518-535. https://doi.org/10.1016/j.rie.2015.11.001 
Li, J., Xu, Z., Yu, L., & Tang, L. (2016, August 6). Forecasting oil price trends with the sentiment of online news articles. Procedia Computer Science. https://www.sciencedirect.com/science/article/pii/S1877050916313503 
Malviya, P., & Bhandari, V. (2023). A systematic study on effective demand prediction using machine learning. Journal of Integrated Science and Technology, 12(1), 711.  https://pubs.thesciencein.org/journal/index.php/jist/article/view/a711 
Middleton, J. (2023). Saudi Aramco’s quarterly profits drop nearly 40% but it still rakes in $30bn. The Guardian. https://www.theguardian.com/business/2023/
aug/07/saudi-aramcos-quarterly-profits-drop-nearly-40-but-it-still-rakes-in-30bn
Simon. (2023). Saudi Aramco’s Disappointing Earnings Are The Least Of Its Problems. https://oilprice.com/Energy/Energy-General/Saudi-Aramcos-
Disappointing-Earnings-Are-The-Least-Of-Its-Problems.html
Tugay, R., & Oguducu, S. G. (2020). Demand prediction using machine learning methods and stacked generalisation. arXiv preprint arXiv:2009.09756. https://doi.org/10.48550/arXiv.2009.09756
U.S. Energy Information Administration. (2023). Short-term Energy Outlook. https://www.eia.gov/outlooks/steo/report/global_oil.php
Russell C. (May 4, 2023). Asia's crude oil imports slip in April amid softer China, India. https://www.reuters.com/markets/commodities/asias-crude-oil-imports-
slip-april-amid-softer-china-india-russell-2023-05-04

![image](https://github.com/YashJain14/Oil_Project/assets/67069635/9d6699d0-52a9-454b-99a5-6cb8e09f9d70)
