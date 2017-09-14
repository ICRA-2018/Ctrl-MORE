/** \file       controlExample.hpp
 * \brief       This is a practical example to implement a new feedback controller
 *
 * \authors     Juan Alejandro Castano (juan.castano@iit.it)
 * \date        2017
 * \version     1.0
 * \copyright   GNU Public License
*/


#ifndef CONTROLEXAMPLE_HPP
#define CONTROLEXAMPLE_HPP

/**
 * License HERE
*/

// second, include other libraries like Eigen, Boost,...
#include <Eigen/Dense>

#include "locomotion/controllers/feedback/FeedbackController.hpp"
#include "locomotion/controllers/feedback/PIDcontrol.hpp"

namespace Locomotion {
///
/// \brief The ControlExample class Provides a descriptive example of a new
/// feedback controller implementation
class ControlExample: public FeedbackController{

public:
    /// \brief Basic constructor
    ControlExample();
    ///
    /// \brief Basic destructor defined as virtual given the existing virtual methods
    virtual ~ControlExample();


    /// \see look feedbackController.hpp to see the virtual functions to be
    /// extended
    /// This is yours run function
    virtual void update( const RobotState& robotState, const ControlState &originalControlState, ControlState *modifiedControlState);
    /// This is your reset
    virtual void reset();
    /// This is your set gains in case of manual modification
    virtual void setGains(const std::map<std::string, double> &gains);
    /// This is your initialization rutine
    virtual void initialize();
    /// This is your load functions.
    virtual bool loadGains(std::string fileName);

protected:

private:

//    std::shared_ptr<PIDcontrol> m_comPid_x;//!< In this example a PID controller is used
//    std::shared_ptr<PIDcontrol> m_comPid_y;//!< In this example a PID controller is used

    Eigen::Vector3d m_newZmpReference; //!< Desired ZMP value
    Eigen::Vector2d m_zmpModification; //!< Modified ZMP value

    Eigen::Vector2d m_pelvisModification; //!< Control effort, in this example a delta

    Eigen::Vector2d m_zmpRef2Meas; //!< reference Mean value
    Eigen::Vector2d m_zmpErrorLim; //!< maximum errorr value

    Eigen::Vector3d m_newComRef; //!< Control effort at COM level, in this example accomulative.

    Eigen::VectorXd m_newPelvisRef; //!< Control effort at pelvis level, in this example accomulative.

    std::shared_ptr<PIDcontrol> m_zmpPid_x, m_zmpPid_y; //!< Two PID controllers are used

    double m_controllCycleTime;
};


}
#endif // CONTROLEXAMPLE_HPP
